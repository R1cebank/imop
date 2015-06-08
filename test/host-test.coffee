module.exports = (assert, expect, config) ->

  describe 'Configuration', () ->
    describe 'Urls', () ->
      it 'should exist', () ->
        expect(config.mongo.url).to.exist
        expect(config.redis.host).to.exist
        expect(config.redis.pass).to.exist
        expect(config.redis.port).to.exist
        expect(config.api.key).to.exist
