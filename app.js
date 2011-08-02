require("coffee-script");
var settings = require('./settings')
var app = settings.app

// Routes
require('./app/routes.coffee')(app);

// Pusher
require('./app/whack');

// Start server
var port = settings.appPort;
app.listen(port, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});
