
/**
 * Module dependencies.
 */

require("coffee-script");
var express     = require('express'),
    RedisStore  = require('connect-redis')(express),
    redisConf   = require("url").parse(process.env.REDISTOGO_URL),
    app         = module.exports = express.createServer(),
    pub         = __dirname + '/public',
    PusherConf  = require("./config").Pusher

// Configuration

app.set('title', 'Node.js Whack-a-Mole');
app.set('redisHost', redisConf.hostname);
app.set('redisPort', redisConf.port);
app.set('redisDb', redisConf.auth.split(":")[0]);
app.set('redisPass', redisConf.auth.split(":")[1]);

app.set('pusherAppKey', PusherConf.key);
app.set('pusherSecret', PusherConf.secret);

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.static(pub));
  app.use(express.cookieParser());
  app.use(express.session({
    secret: "21dae1be4774783b107b77cc30239e0d6a62ffb3573cb773ddf18398eba0622cc95db9f68f4d83216be3dddc5464b293ede9b62bfb4f8a388612caeab423c85e",
    store: new RedisStore({
      db:   app.set('redisDb'),
      host: app.set('redisHost'),
      pass: redisConf.auth.split(":")[1],
      port: app.set('redisPort')
    }),
    cookie: {
      maxAge: 1209600000
    }
  }));
  app.use(app.router);
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// Routes
require('./app/routes.coffee')(app);

// Pusher
var pusher        = require('./pusher');
var game_channel  = pusher.subscribe('private-game');

var port = process.env.PORT || 3000
app.listen(port, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});
