module.exports = (app) ->
  crypto = require('crypto')
  settings = require('../settings')
  pusherClient = settings.pusher.Client
  redisClient = settings.redis
  whack = require('./whack')

  app.get '/', (req, res) ->
    if req.session.nickname
      whack.getUserScores (scores) ->
        res.render 'index', {
          title: app.set('title'),
          currentUserId: req.session.id,
          currentUserNickname: req.session.nickname,
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
    req.session.nickname = escape(req.body.user.nickname)
    refreshUserScore req, () ->
      res.redirect '/'

  app.post '/pusher/auth', (req, res) ->
    res.redirect '/join' unless req.session.nickname
    if req.body.channel_name == 'presence-game' || req.body.channel_name == 'private-game'
      refreshUserScore req, () ->
        req.setEncoding('utf8')

        body = JSON.stringify(pusherClient.createAuthToken(
          req.body.channel_name,
          req.body.socket_id,
          {
            user_id: req.session.id,
            user_info: {
              nickname: req.session.nickname
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
    whack.getUserScore req.session.nickname, (score) ->
      req.session.score = score
      callback()
