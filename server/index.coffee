###
 # I'M OP
 # https://github.com/r1cebank/imop
 # Copyright (c) 2015 Siyuan Gao
 # Licensed under the MIT license
###

express = require 'express'
app = express()

port = process.env.PORT || 3939

app.listen port
