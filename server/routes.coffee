###
          _|
_|_|_|  _|    _|      _|        _|_|    _|_|_|
  _|          _|_|  _|_|      _|    _|  _|    _|
  _|          _|  _|  _|      _|    _|  _|_|_|
  _|          _|      _|      _|    _|  _|
_|_|_|        _|      _|        _|_|    _|

 # I'M OP
 # https://github.com/r1cebank/imop
 # Copyright (c) 2015 Siyuan Gao
 # Licensed under the MIT license
###

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
