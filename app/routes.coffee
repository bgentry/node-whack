module.exports = (app) ->
  app.get '/', (req, res) ->
    console.log(req.session)
    res.render('index', {
      title: app.set('title')
    })

