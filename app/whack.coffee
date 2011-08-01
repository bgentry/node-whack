pusher        = require('../pusher')
pusherClient  = pusher.Client
pusherApi     = pusher.Api
gameChannel   = pusherClient.subscribe('private-game')
gameChannelApi = pusherApi.channel('private-game')

gameChannel.bind 'client-new-game-requested', (data) ->
  console.log "New game starting!"
  gameChannelApi.trigger 'new-game-starting', JSON.stringify({user_id: data.user_id})
