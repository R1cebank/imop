###
 # I'M OP
 # https://github.com/r1cebank/imop
 # Copyright (c) 2015 Siyuan Gao
 # Licensed under the MIT license
###

winston = require 'winston'
server = require './server'

winston.cli()

winston.info 'starting server'
server.config()
server.start()
winston.info 'server started'
