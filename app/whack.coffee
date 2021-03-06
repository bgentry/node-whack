rbytes        = require('rbytes')

settings      = require('../settings')
redis         = require('redis')
redisClient   = settings.redis
pusherClient  = settings.pusher.Client
pusherApi     = settings.pusher.Api
gameChannel   = pusherClient.subscribe('private-game')
gameChannelApi = pusherApi.channel('private-game')

GAME_BOARD_WIDTH = 800
GAME_BOARD_HEIGHT = 600
MOLE_SIZE = 100

gameChannel.bind 'client-new-game-requested', (data) ->
  console.log "New game starting!"
  gameChannelApi.trigger 'new-game-starting', {user_id: data.user_id}
  setTimeout startGame, randomStartDelay(4000, 4000)

gameChannel.bind 'client-whack', (data) ->
  if data.game_token?
    redisClient.get 'current_game_token', (err, current_token) ->
      if data.game_token == current_token
        simpleLock 'whack-lock', () ->
          redisClient.del('current_game_token')
          console.log "Winner! #{data.user_nickname}"
          incrementUserScore data.user_nickname, (new_score) ->
            gameChannelApi.trigger 'game-over', {user_nickname: data.user_nickname, score: new_score}

startGame = () ->
  console.log "Starting Game"
  # Generate game token
  game_token = rbytes.randomBytes(32).toHex()
  # Generate coordinates
  x = Math.floor(Math.random() * (GAME_BOARD_WIDTH - MOLE_SIZE))
  y = Math.floor(Math.random() * (GAME_BOARD_HEIGHT - MOLE_SIZE))
  redisClient.setex('current_game_token', 20, game_token, redis.print)
  gameChannelApi.trigger 'new-game', {game_token: game_token, position: {x: x, y: y}}

randomStartDelay = (minimum, spread) ->
  Math.random()*spread + minimum

getUserScores = (callback) ->
  redisClient.zrangebyscore 'scoreboard', 1, '+inf', 'WITHSCORES', (err, replies) ->
    if err
      console.log "Error in getUserScores: #{err}"
      throw err
    else
      result = {}
      current_user = null
      replies.forEach (reply, i) ->
        if i % 2
          result[current_user] = reply
        else
          current_user = reply
      callback(result)
exports.getUserScores = getUserScores

getUserScore = (user_nickname, callback) ->
  redisClient.zscore 'scoreboard', user_nickname, (err, reply) ->
    if err
      console.log "Error in getUserScore: #{err}"
      throw err
    else
      callback(reply || 0)
exports.getUserScore = getUserScore

incrementUserScore = (user_nickname, callback, amount = 1) ->
  redisClient.zincrby 'scoreboard', amount, user_nickname, (err, reply) ->
    callback(reply)

simpleLock = (lock_key, callback) ->
  redisClient.setnx lock_key, 1, (err, setNxReply) ->
    console.log "setNxReply:"
    console.log setNxReply
    if setNxReply == 1
      callback()
      redisClient.del lock_key
    else
      console.log "No lock acquired"

acquireLock = (lock_key, callback, timeout = 500) ->
  now = Date.now()
  expireAt = now + timeout
  redisClient.setnx lock_key, expireAt, (err, setNxReply) ->
    console.log "setNxReply:"
    console.log setNxReply
    if setNxReply == 1
      callback()
    else
      redisClient.get lock_key, (err, currentTimeout) ->
        console.log "< now? #{currentTimeout < now}"
        console.log "c #{currentTimeout}"
        console.log "n #{now}"
        if currentTimeout < now
          redisClient.getset lock_key, expireAt, (err, newTimeout) ->
            console.log "== #{newTimeout == expireAt}"
            if newTimeout == expireAt
              callback()
              redisClient.del lock_key
