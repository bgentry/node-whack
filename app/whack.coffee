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
      data.game_token == reply
      redisClient.del('current_game_token')
      console.log "Winner! #{data.user_id}"
      gameChannelApi.trigger 'game-over', {user_id: data.user_id}

startGame = () ->
  console.log "Starting Game"
  game_token = rbytes.randomBytes(32).toHex()
  redisClient.setex('current_game_token', 20, game_token, redis.print)
  gameChannelApi.trigger 'new-game', {game_token: game_token}

randomStartDelay = (minimum, spread) ->
  Math.random()*spread + minimum
