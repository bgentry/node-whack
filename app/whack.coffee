rbytes        = require('rbytes')

settings      = require('../settings')
redis         = require('redis')
redisClient   = settings.redis
pusherClient  = settings.pusher.Client
pusherApi     = settings.pusher.Api
gameChannel   = pusherClient.subscribe('private-game')
gameChannelApi = pusherApi.channel('private-game')

gameChannel.bind 'client-new-game-requested', (data) ->
  console.log "New game starting!"
  gameChannelApi.trigger 'new-game-starting', {user_id: data.user_id}
  setTimeout startGame, randomStartDelay(4000, 4000)

gameChannel.bind 'client-whack', (data) ->
  if data.game_token?
    redisClient.get 'current_game_token', (err, reply) ->
      if data.game_token == reply
        simpleLock 'whack-lock', () ->
          redisClient.del('current_game_token')
          console.log "Winner! #{data.user_id}"
          redisClient.hincrby 'scoreboard', data.user_id, 1, (err, reply) ->
            gameChannelApi.trigger 'game-over', {user_id: data.user_id, score: reply}

startGame = () ->
  console.log "Starting Game"
  game_token = rbytes.randomBytes(32).toHex()
  redisClient.setex('current_game_token', 20, game_token, redis.print)
  gameChannelApi.trigger 'new-game', {game_token: game_token}

randomStartDelay = (minimum, spread) ->
  Math.random()*spread + minimum

getUserScore = (user_email, callback) ->
  redisClient.hget 'scoreboard', user_email, (err, reply) ->
    callback(reply || 0)
exports.getUserScore = getUserScore

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
