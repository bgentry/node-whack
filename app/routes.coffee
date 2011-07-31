module.exports = (app) ->
  app.get '/', (req, res) ->
    if req.session.email
      console.log "Email: #{req.session.email}"
      res.render 'index', {
        title: app.set('title')
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
