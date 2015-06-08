###
 # I'M OP (Tests - Mocha/Chai)
 # https://github.com/r1cebank/imop
 # Copyright (c) 2015 Siyuan Gao
 # Licensed under the MIT license
###

# Chai BDD
chai = require 'chai'
assert = chai.assert
expect = chai.expect
config = require '../config/server-config.json'


require('./host-test.coffee')(assert, expect, config)
