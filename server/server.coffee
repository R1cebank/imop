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

express = require 'express'
hbs = require 'hbs'
path = require 'path'
app = express()

# require config and static files
config = require './config/server-config.json'

# require custom files
routes = require('./routes')()
serveHandler = require('./handlers/serve')(config)
summonerHandler = require('./handlers/summoner')()

handlers =
  serve: serveHandler
  summoner: summonerHandler

configure = () ->
  # Setting up view engine for html
  app.set 'view engine', 'html'
  app.engine 'html', hbs.__express
  app.set 'views', path.join __dirname, 'views/'
  # Hosting public files for express
  app.use express.static path.join __dirname, 'views/public/'

start = () ->
  routes.setup app, handlers
  port = process.env.PORT || 3939
  app.listen port

exports.config = configure
exports.start = start
exports.app = app
