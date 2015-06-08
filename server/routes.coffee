module.exports = () ->
  #initiate self
  self = { }

  self.setup = (app, handlers) ->
    # routes fron handlers
    app.get '/', handlers.serve.root
    app.get '/riot.txt', handlers.serve.key
    app.get '/summoner/:name/update', handlers.summoner.update
    app.get '/summoner/:name', handlers.summoner.get

  return self
