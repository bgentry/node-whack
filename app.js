
/**
 * Module dependencies.
 */

var express     = require('express');
var RedisStore  = require('connect-redis')(express)
var redisConf  = require("url").parse(process.env.REDISTOGO_URL)
var app         = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
  app.use(express.cookieParser());
  app.use(express.session({
    secret: "21dae1be4774783b107b77cc30239e0d6a62ffb3573cb773ddf18398eba0622cc95db9f68f4d83216be3dddc5464b293ede9b62bfb4f8a388612caeab423c85e",
    store: new RedisStore({
      port: redisConf.port,
      host: redisConf.hostname,
      pass: redisConf.auth.split(":")[1]
    }),
    cookie: {
      maxAge: 60000
    }
  }));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

app.configure('production', function(){
  app.use(express.errorHandler()); 
});

// Routes

app.get('/', function(req, res){
  res.render('index', {
    title: 'Express'
  });
});

var port = process.env.PORT || 3000
app.listen(port, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});
