module.exports = (app) ->
  Pusher      = require('pusher')
  pusherConf  = require("url").parse(process.env.PUSHER_URL)

  app.set 'pusherAppKey',pusherConf.auth.split(':')[0]
  app.set 'pusherSecret',pusherConf.auth.split(':')[1]
  app.set 'pusher', new Pusher({
    appId:  pusherConf.pathname.split('/')[2],
    appKey: app.set('pusherAppKey'),
    secret: app.set('pusherSecret')
  })
