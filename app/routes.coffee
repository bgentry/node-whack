module.exports = (app) ->
  crypto = require('crypto')

  app.get '/', (req, res) ->
    if req.session.email
      console.log "Email: #{req.session.email}"
      res.render 'index', {
        title: app.set('title'),
        pusherAppKey: app.set('pusherAppKey')
      }
    else
      res.redirect '/join'

  app.get '/join', (req, res) ->
    res.render 'join', {
      title: ['Signup', app.set('title')].join(' - ')
    }

  app.post '/join', (req, res) ->
    req.session.email = req.body.user.email
    res.redirect '/'

  app.post '/pusher/auth', (req, res) ->
    res.redirect '/join' unless req.session.email
    if req.body.channel_name == 'presence-game' || req.body.channel_name == 'private-game-events'
      res.contentType 'json'
      if /^presence-/.test(req.body.channel_name)
        channel_data = JSON.stringify({ user_id: req.session.id, user_info: {email: req.session.email } })
        auth_sig = authChannel(req.body.socket_id, req.body.channel_name, channel_data)
        res.send {
          auth: [app.set('pusherAppKey'), auth_sig].join(':'),
          channel_data: channel_data
        }
      else
        auth_sig = authChannel(req.body.socket_id, req.body.channel_name)
        res.send {
          auth: [app.set('pusherAppKey'), auth_sig].join(':')
        }
    else res.send 403

  authChannel = (socket_id, channel_name, channel_data = null) ->
    auth_string = if channel_data
      [socket_id, channel_name, channel_data].join(':')
    else
      [socket_id, channel_name].join(':')
    console.log "Signing " + auth_string
    hmac = crypto.createHmac('sha256', app.set('pusherSecret'))
    hmac.update(auth_string)
    hmac.digest('hex')
