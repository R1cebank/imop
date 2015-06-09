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

module.exports = (assert, expect, config) ->

  describe 'Configuration', () ->
    describe 'Urls', () ->
      it 'should exist', () ->
        expect(config.mongo.url).to.exist
        expect(config.redis.host).to.exist
        expect(config.redis.pass).to.exist
        expect(config.redis.port).to.exist
        expect(config.api.key).to.exist
