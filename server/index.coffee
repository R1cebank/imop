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

winston = require 'winston'
server = require './server'
utils = require './utils'

# start the logging cli
winston.cli()

# print the product logo
utils.printlogo()

# start the server
winston.info 'starting server'
server.config()
server.start()
winston.info 'server started'
