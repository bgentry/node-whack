;(function(exports, undefined) {
  pusherConf  = require("url").parse(process.env.PUSHER_URL)
  exports.Pusher = {
    appId:  pusherConf.pathname.split('/')[2],
    key:    pusherConf.auth.split(':')[0],
    secret: pusherConf.auth.split(':')[1]
  }
})((typeof exports !== 'undefined' ? exports : this));
