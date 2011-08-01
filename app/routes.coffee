module.exports = (app) ->
  crypto = require('crypto')
  pusher = require('../pusher')

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
      req.setEncoding('utf8')

      body = JSON.stringify(pusher.createAuthToken(
        req.body.channel_name,
        req.body.socket_id,
        {
          user_id: req.session.id,
          user_info: {
            email: req.session.email
          }
        }
      ))

      res.writeHead(200, {
        'Content-Length': body.length,
        'Content-Type': 'application/json'
      })
      res.end(body)
    else res.send 403
