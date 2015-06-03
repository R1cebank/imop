
/*
  * I'M OP
  * https://github.com/r1cebank/imop
  * Copyright (c) 2015 Siyuan Gao
  * Licensed under the MIT license
 */

(function() {
  var Client, Irelia, Promise, Q, _, api, api_key, championStatic, client, matchAPI;

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

  matchAPI = 'https://global.api.pvp.net/api/lol/na/v2.2/match/';

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
    self.getMatchInfo = function(id) {
      var promise;
      promise = new Promise(function(resolve, reject) {
        return client.get("" + matchAPI + id + "?api_key=" + api_key, function(data, res) {
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
      var creepScore, damageMultifier, dmgScore, finalScore1, goldScore, ipScore, ratioPackage, score, wardScore;
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
      console.log("dmg mult: " + damageMultifier);
      wardScore = (data.stats.wardPlaced / 10) * 0.2;
      dmgScore = (data.stats.totalDamageDealt / data.stats.totalDamageTaken) * 0.3 * damageMultifier;
      goldScore = (data.stats.goldEarned / data.stats.goldSpent) * 0.1;
      creepScore = ((data.stats.minionsKilled / (data.stats.timePlayed / 60)) / 6) * 0.4;
      if (isNaN(wardScore)) {
        wardScore = 0.035;
      }
      if (isNaN(dmgScore)) {
        wardScore = 0.3 * damageMultifier;
      }
      if (isNaN(goldScore)) {
        wardScore = 0.109;
      }
      if (isNaN(creepScore)) {
        wardScore = 0.16667;
      }
      console.log('#################');
      console.log("" + wardScore);
      console.log(dmgScore + "}");
      console.log("" + goldScore);
      console.log("" + creepScore);
      console.log('#################');
      finalScore1 = wardScore + dmgScore + goldScore + creepScore;
      if (finalScore1 < 1) {
        finalScore1 = finalScore1 * 100;
      } else {
        ipScore = (data.ipEarned / 144) * 0.1;
        console.log("before adjust: " + finalScore1);
        score = (finalScore1 / Math.ceil(finalScore1)) * 0.9;
        console.log("ipScore " + ipScore + " score " + score);
        finalScore1 = (ipScore + score) * 100;
      }
      console.log(finalScore1);
      return finalScore1;
    };
    return self;
  };

}).call(this);
