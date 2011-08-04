module.exports = (app) ->
  crypto = require('crypto')
  settings = require('../settings')
  pusherClient = settings.pusher.Client
  redisClient = settings.redis
  whack = require('./whack')

  app.get '/', (req, res) ->
    if req.session.email
      whack.getUserScores (scores) ->
        res.render 'index', {
          title: app.set('title'),
          currentUserId: req.session.id,
          currentUserEmail: req.session.email,
          pusherAppKey: app.set('pusherAppKey'),
          scores: scores
        }
    else
      res.redirect '/join'

  app.get '/join', (req, res) ->
    res.render 'join', {
      title: ['Signup', app.set('title')].join(' - ')
    }

  app.post '/join', (req, res) ->
    req.session.email = escape(req.body.user.email)
    refreshUserScore req, () ->
      res.redirect '/'

  app.post '/pusher/auth', (req, res) ->
    res.redirect '/join' unless req.session.email
    if req.body.channel_name == 'presence-game' || req.body.channel_name == 'private-game'
      refreshUserScore req, () ->
        req.setEncoding('utf8')

        body = JSON.stringify(pusherClient.createAuthToken(
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

  refreshUserScore = (req, callback) ->
    whack.getUserScore req.session.email, (score) ->
      req.session.score = score
      callback()
