
/*
  * I'M OP
  * https://github.com/r1cebank/imop
  * Copyright (c) 2015 Siyuan Gao
  * Licensed under the MIT license
 */

(function() {
  var Q, _, app, championMap, champions, config, express, hbs, model, path, port;

  express = require('express');

  app = express();

  hbs = require('hbs');

  path = require('path');

  Q = require('q');

  _ = require('lodash');

  config = require('./config/server-config.json');

  champions = require('./config/champion.json');

  championMap = {};

  Object.keys(champions.data).forEach(function(key) {
    return championMap[champions.data[key].key] = key;
  });

  model = require('./models.js')();

  app.set('view engine', 'html');

  app.engine('html', hbs.__express);

  app.set('views', path.join(__dirname, 'views/'));

  app.use(express["static"](path.join(__dirname, 'views/public/')));

  app.get('/', function(req, res) {
    return res.render('index');
  });

  app.get('/riot.txt', function(req, res) {
    return res.send('997c3ed4-8103-481c-8cec-42e688efd5c5');
  });

  app.get('/summoner/:name', function(req, res) {
    var gameData, hdbData, summary, summoner, summonerData, summonerName;
    summonerName = req.params['name'];
    summonerData = {};
    gameData = [];
    summary = {};
    hdbData = {};
    console.log("User " + req.params['name'] + " querying");
    summoner = model.getSummonerByName(summonerName);
    return summoner.then(function(data) {
      summonerData = data[summonerName.toLowerCase().replace(/\s+/g, '')];
      return hdbData = {
        name: summonerData['name'],
        level: summonerData['summonerLevel'],
        iconid: summonerData['profileIconId']
      };
    }).then(function() {
      return summary = model.getSummary(summonerData['id']);
    }).then(function(data) {
      var j, len, map, ref, row;
      map = {};
      ref = data['playerStatSummaries'];
      for (j = 0, len = ref.length; j < len; j++) {
        row = ref[j];
        map[row.playerStatSummaryType] = row.wins;
      }
      hdbData['unranked'] = map['Unranked'];
      return hdbData['RankedSolo5x5'] = map['RankedSolo5x5'];
    }).then(function() {
      var recent;
      return recent = model.getRecentGames(summonerData['id']);
    }).then(function(data) {
      var gameResult, games, j, len, playerDataPromises, row, teamID;
      playerDataPromises = [];
      games = data['games'];
      for (j = 0, len = games.length; j < len; j++) {
        row = games[j];
        teamID = row.teamId;

        /*for player in row.fellowPlayers
          if teamID == player.teamId
            players.push player.summonerId
         */
        gameResult = "lose";
        if (row.stats.win) {
          gameResult = "win";
        }
        if (row.championId === 0) {
          continue;
        }
        gameData.push({
          subtype: row.subType.toLowerCase(),
          kill: row.stats.championsKilled,
          death: row.stats.numDeaths,
          assist: row.stats.assists,
          level: row.stats.level,
          kda: (row.stats.championsKilled / row.stats.numDeaths).toFixed(3),
          cs: row.stats.minionsKilled,
          timeM: Math.floor(row.stats.timePlayed / 60),
          timeS: row.stats.timePlayed - Math.floor(row.stats.timePlayed / 60) * 60,
          result: gameResult,
          championID: row.championId,
          multiKill: row.stats.largestMultiKill,
          gold: (row.stats.goldEarned / 1000).toFixed(3),
          ward: row.stats.wardPlaced,
          ip: row.ipEarned,
          killpermin: (row.stats.championsKilled / Math.floor(row.stats.timePlayed / 60)).toFixed(3),
          score: model.calculateOPS(row),
          matchID: row.gameId
        });
      }
      return hdbData['gamedata'] = gameData;
    }).then(function() {
      return _.each(gameData, function(d) {
        if (championMap[d.championID] === void 0) {
          d.url = 'http://motiondex.com/NC.png';
          d.championName = 'new champion';
        } else {
          d.championName = championMap[d.championID];
          d.url = "http://ddragon.leagueoflegends.com/cdn/5.2.1/img/champion/" + championMap[d.championID] + ".png";
        }
        if (isNaN(d.kda)) {
          d.kda = d.kill;
        }
        return Object.keys(d).forEach(function(key) {
          if (d[key] === void 0) {
            return d[key] = 0;
          }
        });
      });
    }).then(function() {
      var arrayX, arrayY;
      arrayX = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
      arrayY = [];
      _.each(gameData, function(d, i) {
        return arrayY.push(d.score);
      });
      return hdbData['chart1'] = "<script> new Chartist.Line('.perf-chart', { labels: [" + (arrayX.join(",")) + "], series: [ [" + (arrayY.join(",")) + "] ] }, { fullWidth: true, chartPadding: { right: 40 } }); </script>";
    }).then(function() {
      console.log('sending response back');
      return res.render('mainView', hdbData);
    });
  });

  port = process.env.PORT || 3939;

  app.listen(port);

}).call(this);
