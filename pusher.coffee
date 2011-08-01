PusherConf    = require('./config').Pusher
PusherClient  = require('./lib/pusher')
PusherApi     = require('pusher')

exports.Client = new PusherClient(PusherConf.key, {
  secret_key: PusherConf.secret,
  channel_data: {
    user_id: 'SERVER',
    user_info: {}
  }
})

exports.Api = new PusherApi({
  appId:  PusherConf.appId,
  appKey: PusherConf.key,
  secret: PusherConf.secret
})
