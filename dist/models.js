
/*
  * I'M OP
  * https://github.com/r1cebank/imop
  * Copyright (c) 2015 Siyuan Gao
  * Licensed under the MIT license
 */

(function() {
  var Client, Irelia, Promise, Q, _, api, api_key, championStatic, client;

  api_key = 'b1d29328-72ca-4d03-b9e2-be254f4379d6';

  Client = require('node-rest-client').Client;

  client = new Client();

  Irelia = require('irelia');

  api = new Irelia({
    secure: true,
    host: 'na.api.pvp.net',
    path: '/api/lol/',
    key: api_key,
    debug: false
  });

  Promise = require('promise');

  Q = require('q');

  _ = require('lodash');

  championStatic = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion/';

  module.exports = function() {
    var self;
    self = {};
    self.getSummonerByName = function(name) {
      var promise;
      promise = new Promise(function(resolve, reject) {
        return api.getSummonerByName('na', name, function(error, result) {
          if (error) {
            return reject(error);
          } else {
            return resolve(result);
          }
        });
      });
      return promise;
    };
    self.getRecentGames = function(id) {
      var promise;
      promise = new Promise(function(resolve, reject) {
        return api.getRecentGamesBySummonerId('na', id, function(error, result) {
          if (error) {
            return reject(error);
          } else {
            return resolve(result);
          }
        });
      });
      return promise;
    };
    self.getSummary = function(id) {
      var promise;
      promise = new Promise(function(resolve, reject) {
        return api.getSummaryStatsBySummonerId('na', id, function(error, result) {
          if (error) {
            return reject(error);
          } else {
            return resolve(result);
          }
        });
      });
      return promise;
    };
    self.getSummonerById = function(id) {
      var promise;
      promise = new Promise(function(resolve, reject) {
        return api.getSummonerBySummonerId('na', id, function(error, result) {
          if (error) {
            return reject(error);
          } else {
            return resolve(result);
          }
        });
      });
      return promise;
    };
    self.getSummonersById = function(ids) {
      var promise;
      promise = new Promise(function(resolve, reject) {
        return api.getSummonersBySummonerIds('na', ids, function(error, result) {
          if (error) {
            return reject(error);
          } else {
            return resolve(result);
          }
        });
      });
      return promise;
    };
    self.getChampions = function() {
      var promise;
      promise = new Promise(function(resolve, reject) {
        return api.getChampions('na', function(error, result) {
          if (error) {
            return reject(error);
          } else {
            return resolve(result);
          }
        });
      });
      return promise;
    };
    self.getChampionInfo = function(id) {
      var promise;
      promise = new Promise(function(resolve, reject) {
        return client.get("" + championStatic + id + "?api_key=" + api_key, function(data, res) {
          if (data === void 0) {
            return reject(res);
          } else {
            return resolve(data);
          }
        });
      });
      return promise;
    };
    self.calculateOPS = function(data) {
      var damageMultifier, ratioPackage;
      ratioPackage = {
        damageRatio: data.stats.totalDamageDealt / data.stats.totalDamageTaken,
        kda: data.stats.championsKilled / data.stats.numDeaths,
        damageUntilDeath: data.stats.totalDamageDealt / data.stats.numDeaths,
        damageUntilKill: data.stats.totalDamageTaken / data.stats.championsKilled,
        turretModifier: data.stats.turretsKilled / (data.stats.timePlayed / 60)
      };
      Object.keys(ratioPackage).forEach(function(key) {
        if (isNaN(ratioPackage[key])) {
          return ratioPackage[key] = 0.055;
        }
      });
      damageMultifier = ratioPackage.kda * ratioPackage.damageRatio * ratioPackage.turretModifier;
      return console.log(damageMultifier);
    };
    return self;
  };

}).call(this);
