
/*
  * I'M OP
  * https://github.com/r1cebank/imop
  * Copyright (c) 2015 Siyuan Gao
  * Licensed under the MIT license
 */

(function() {
  var Q, app, express, hbs, model, path, port;

  express = require('express');

  app = express();

  hbs = require('hbs');

  path = require('path');

  Q = require('q');

  model = require('./models.js')();

  app.set('view engine', 'html');

  app.engine('html', hbs.__express);

  app.set('views', path.join(__dirname, 'views/'));

  app.use(express["static"](path.join(__dirname, 'views/public/')));

  app.get('/', function(req, res) {
    return res.render('index');
  });

  app.get('/summoner/:name', function(req, res) {
    var hdbData, summary, summoner, summonerData, summonerName;
    summonerName = req.params['name'];
    summonerData = {};
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
      var i, len, map, ref, row;
      map = {};
      ref = data['playerStatSummaries'];
      for (i = 0, len = ref.length; i < len; i++) {
        row = ref[i];
        map[row.playerStatSummaryType] = row.wins;
      }
      hdbData['unranked'] = map['Unranked'];
      return hdbData['RankedSolo5x5'] = map['RankedSolo5x5'];
    }).then(function() {
      var recent;
      return recent = model.getRecentGames(summonerData['id']);
    }).then(function(data) {
      var gameData, games, i, len, row;
      gameData = [];
      games = data['games'];
      for (i = 0, len = games.length; i < len; i++) {
        row = games[i];
        gameData.push({
          subtype: row.subType.toLowerCase(),
          kill: row.stats.championsKilled,
          death: row.stats.numDeaths,
          assist: row.stats.assists,
          level: row.stats.level,
          kda: (row.stats.championsKilled / row.stats.numDeaths).toFixed(3),
          cs: row.stats.minionsKilled
        });
      }
      console.log(gameData);
      return hdbData['gamedata'] = gameData;
    }).then(function() {
      console.log('sending response back');
      return res.render('mainView', hdbData);
    });
  });

  port = process.env.PORT || 3939;

  app.listen(port);

}).call(this);
