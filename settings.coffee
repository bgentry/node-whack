express     = require('express')
RedisStore  = require('connect-redis')(express)
redisConf   = require("url").parse(process.env.REDISTOGO_URL)
pub         = __dirname + '/public'
app         = express.createServer()
exports.app = app

pusherUrl   = require("url").parse(process.env.PUSHER_URL)
pusherConf  = {
  appId:  pusherUrl.pathname.split('/')[2],
  key:    pusherUrl.auth.split(':')[0],
  secret: pusherUrl.auth.split(':')[1]
}

PusherClient  = require('./lib/pusher')
PusherApi     = require('pusher')
exports.pusher = {
  Client: new PusherClient(pusherConf.key, {
    secret_key: pusherConf.secret,
    channel_data: {
      user_id: 'SERVER',
      user_info: {}
    }
  })

  Api: new PusherApi({
    appId:  pusherConf.appId,
    appKey: pusherConf.key,
    secret: pusherConf.secret
  })
}

exports.appPort = process.env.PORT || 3000
exports.REDIS_PORT = redisConf.port
exports.REDIS_HOST = redisConf.hostname
exports.REDIS_PASS = redisConf.auth.split(":")[1]

redis       = require('redis')
redisClient = redis.createClient(exports.REDIS_PORT, exports.REDIS_HOST)
redisClient.auth(exports.REDIS_PASS)

exports.debug = true

app.set('title', 'Node.js Whack-a-Mole')
app.set('pusherAppKey', pusherConf.key)

app.configure () ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.static(pub))
  app.use(express.cookieParser())
  app.use(express.session({
    secret: "21dae1be4774783b107b77cc30239e0d6a62ffb3573cb773ddf18398eba0622cc95db9f68f4d83216be3dddc5464b293ede9b62bfb4f8a388612caeab423c85e",
    store: new RedisStore({
      host: exports.REDIS_HOST,
      pass: exports.REDIS_PASS,
      port: exports.REDIS_PORT
    }),
    cookie: {
      maxAge: 1209600000
    }
  }))
  app.use(app.router)

app.configure 'development', () ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', () ->
  app.use(express.errorHandler())
