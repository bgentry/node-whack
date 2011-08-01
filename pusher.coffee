PusherConf  = require('./config').Pusher
Pusher = require('./lib/pusher')
module.exports = new Pusher(PusherConf.key, {
  secret_key: PusherConf.secret,
  channel_data: {
    user_id: 'SERVER',
    user_info: {}
  }
})
