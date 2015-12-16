###
 # I'M OP
 # https://github.com/r1cebank/imop
 # Copyright (c) 2015 Siyuan Gao
 # Licensed under the MIT license
###

# Main server file

# require config and static files
config = require './config/server-config.json'
champions = require './config/champion.json'
championMap = {}

# Required Libs
express = require 'express'

app = express()
mongo = require('mongodb').MongoClient
redis = require 'redis'

# creates redis client
redisClient = redis.createClient config.redisPort, config.redisHost
# auth the client using pass
redisClient.auth config.redisPass

redisClient.on 'connect', () ->
  console.log 'redis server connected'


hbs = require 'hbs'
path = require 'path'
Q = require 'q'
_ = require 'lodash'

# construct champion name and ID map
Object.keys(champions.data).forEach (key) ->
  championMap[champions.data[key].key] = key

# require models
model = require('./models.js')()

# Setting up view engine for html
app.set 'view engine', 'html'
app.engine 'html', hbs.__express
app.set 'views', path.join __dirname, 'views/'

# Hosting public files for express
app.use express.static path.join __dirname, 'views/public/'

# Serves the main page
app.get '/', (req, res) ->
  res.render 'index'

# used for riot application verification
app.get '/riot.txt', (req, res) ->
  res.send 'e6303483-9e74-4d9f-af72-74006b02bb1c'

app.get '/summoner/:name/update', (req, res) ->
  # data
  summonerName = req.params['name']
  # get the username from url
  console.log "User #{req.params['name']} refreshing"

  # push the update to mongodb
  databaseConnect = model.connectDB config.mongoUrl
  databaseConnect.then (db) ->
    # connected to database
    console.log "connected to database"

    # get the collection
    summoner = db.collection('summoner')

    deletePromise = model.remove summoner, summonerName
  .then (collection) ->
    console.log "post deleted, updating"
    res.redirect("/summoner/#{summonerName}")

app.get '/summoner/:name', (req, res) ->
  # data
  summonerName = req.params['name']
  summonerData = { }
  gameData = [ ]
  summary = { }
  hdbData = { }

  # get the username from url
  console.log "User #{req.params['name']} querying"

  # connect to database promise
  databaseConnect = model.connectDB config.mongoUrl
  databaseConnect.then (db) ->
    # connected to databse
    console.log "connected to database"

    # get the collection
    summoner = db.collection('summoner')

    #create a new promise to lookup
    lookup = model.lookup summoner, summonerName
  .then (doc) ->
    if doc
      # renders the main view
      console.log "found record"
      res.render 'mainView', doc
    else
      # get a promise for summoner info
      summoner = model.getSummonerByName summonerName
      summoner.then (data) ->
        summonerData = data[summonerName.toLowerCase().replace /\s+/g, '']
        hdbData =
          name: summonerData['name']
          level: summonerData['summonerLevel']
          iconid: summonerData['profileIconId']

      .then () ->

        # create a new promise query for the summoner summary
        summary = model.getSummary summonerData['id']

      .then (data) ->

        # using the summary data from the promise
        # create a map
        map = { }
        for row in data['playerStatSummaries']
          map[row.playerStatSummaryType] = row.wins
        hdbData['unranked'] = map['Unranked']
        hdbData['RankedSolo5x5'] = map['RankedSolo5x5']
      .then () ->

        # create a new promise for recent matches
        recent = model.getRecentGames summonerData['id']

      .then (data) ->

        # using the data to get metrics
        # players = [ ]
        playerDataPromises = [ ]
        games = data['games']

        # contruct the array for template
        for row in games
          teamID = row.teamId
          ###for player in row.fellowPlayers
            if teamID == player.teamId
              players.push player.summonerId
          ###

          # console.log players
          # setting win or lose

          gameResult = "lose"
          gameResult = "win" if row.stats.win

          # eliminate ones with no champion
          if row.championId is 0
            continue

          gameData.push
            subtype: row.subType.toLowerCase()  # game type
            kill:    row.stats.championsKilled
            death:   row.stats.numDeaths
            assist:  row.stats.assists
            level:   row.stats.level
            kda:     ((row.stats.championsKilled + row.stats.assists) / row.stats.numDeaths).toFixed(3)
            cs:      row.stats.minionsKilled
            timeM:   Math.floor(row.stats.timePlayed / 60)
            timeS:   row.stats.timePlayed-Math.floor(row.stats.timePlayed / 60) * 60
            result:  gameResult
            championID: row.championId
            multiKill:  row.stats.largestMultiKill
            gold:       (row.stats.goldEarned / 1000).toFixed(3)
            ward:       row.stats.wardPlaced
            ip:         row.ipEarned
            killpermin: (row.stats.championsKilled /
            Math.floor(row.stats.timePlayed / 60)).toFixed(3)
            score:         model.calculateOPS(row)
            matchID:    row.gameId

          # playerDataPromises.push model.getSummonersById players

          # players = [ ]

        # console.log gameData
        hdbData['gamedata'] = gameData
        # pass array to get player info
        # return Promise.all(playerDataPromises)
      .then () ->
        _.each gameData, (d) ->
          if championMap[d.championID] is undefined
            d.url = 'http://motiondex.com/NC.png'
            d.championName = 'new champion'
          else
            d.championName = championMap[d.championID]
            d.url = "http://ddragon.leagueoflegends.com/cdn/5.2.1/img/champion/#{championMap[d.championID]}.png"

          if isNaN d.kda
            d.kda = d.kill
          Object.keys(d).forEach (key) ->
            if d[key] is undefined
              d[key] = 0

      .then () ->

        # performance chart 1

        # construct X array
        arrayX = ['1','2','3','4','5', '6', '7' ,'8', '9', '10']

        # construct Y array
        arrayY = []
        _.each gameData, (d, i) ->
          arrayY.push d.score


        hdbData['chart1'] = "<script>
        new Chartist.Line('.perf-chart', {
          labels: [#{arrayX.join(",")}],
          series: [
            [#{arrayY.join(",")}]
          ]
        }, {
          fullWidth: true,
          chartPadding: {
            right: 40
          }
        });
        </script>"
      .then () ->
        # building chart #2
        # construct X array
        arrayX = ['1','2','3','4','5', '6', '7' ,'8', '9', '10']

        # construct Y array
        arrayY = []
        _.each gameData, (d, i) ->
          arrayY.push (d.cs / d.timeM)


        hdbData['chart2'] = "<script>
        new Chartist.Line('.cs-chart', {
          labels: [#{arrayX.join(",")}],
          series: [
            [#{arrayY.join(",")}]
          ]
        }, {
          fullWidth: true,
          chartPadding: {
            right: 40
          }
        });
        </script>"
      .then () ->
        # building chart #3
        # construct X array
        arrayX = ['1','2','3','4','5', '6', '7' ,'8', '9', '10']

        # construct Y array
        arrayY = []
        _.each gameData, (d, i) ->
          arrayY.push d.kda


        hdbData['chart3'] = "<script>
        new Chartist.Line('.kda-chart', {
          labels: [#{arrayX.join(",")}],
          series: [
            [#{arrayY.join(",")}]
          ]
        }, {
          fullWidth: true,
          chartPadding: {
            right: 40
          }
        });
        </script>"
      .then () ->
        # building chart #4
        # construct X array
        arrayX = ['1','2','3','4','5', '6', '7' ,'8', '9', '10']

        # construct Y array
        arrayY = []
        _.each gameData, (d, i) ->
          arrayY.push d.killpermin


        hdbData['chart4'] = "<script>
        new Chartist.Line('.kpm-chart', {
          labels: [#{arrayX.join(",")}],
          series: [
            [#{arrayY.join(",")}]
          ]
        }, {
          fullWidth: true,
          chartPadding: {
            right: 40
          }
        });
        </script>"
      .then () ->
        # building chart #5
        # construct X array
        arrayX = ['1','2','3','4','5', '6', '7' ,'8', '9', '10']

        # construct Y array
        arrayY = []
        _.each gameData, (d, i) ->
          arrayY.push (d.gold / d.timeM * 1000)


        hdbData['chart5'] = "<script>
        new Chartist.Line('.gpm-chart', {
          labels: [#{arrayX.join(",")}],
          series: [
            [#{arrayY.join(",")}]
          ]
        }, {
          fullWidth: true,
          chartPadding: {
            right: 40
          }
        });
        </script>"
      .then () ->
        # push the update to mongodb
        databaseConnect = model.connectDB config.mongoUrl
      .then (db) ->
        # connected to database
        console.log "connected to database"

        # get the collection
        summoner = db.collection('summoner')

        deletePromise = model.remove summoner, hdbData['name']
      .then (collection) ->

        console.log "record deleted"
        # insert promise
        insertPromise = model.insert summoner, hdbData

      .then (docs) ->
        console.log "record inserted"
        # inserting redis record

        redisPromise = model.insertRedis redisClient, hdbData, hdbData['name'].toLowerCase()
      .then (resolt) ->
        console.log 'redis record inserted'
        console.log 'sending response back'
        res.render 'mainView', hdbData
        # renders the main view
      .catch (e) ->
        if e.statusCode is 404
          res.render 'notFound', name: summonerName

app.use (req, res) ->
  res.status 400
  res.render '404.jade', title: '404: File Not Found'
port = process.env.PORT || 3939

app.listen port
