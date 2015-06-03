###
 # I'M OP
 # https://github.com/r1cebank/imop
 # Copyright (c) 2015 Siyuan Gao
 # Licensed under the MIT license
###

# Main server file

# Required Libs
express = require 'express'
app = express()
hbs = require 'hbs'
path = require 'path'
Q = require 'q'

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

app.get '/summoner/:name', (req, res) ->
  # data
  summonerName = req.params['name']
  summonerData = { }
  summary = { }
  hdbData = { }
  # get the username from url
  console.log "User #{req.params['name']} querying"
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
    gameData = [ ]
    games = data['games']
    # contruct the array for template
    for row in games
      gameData.push
        subtype: row.subType.toLowerCase()
        kill:    row.stats.championsKilled
        death:   row.stats.numDeaths
        assist:  row.stats.assists
        level:   row.stats.level
        kda:     (row.stats.championsKilled / row.stats.numDeaths).toFixed(3)
        cs:      row.stats.minionsKilled

    console.log gameData
    hdbData['gamedata'] = gameData
  .then () ->
    console.log 'sending response back'
    res.render 'mainView', hdbData
    # renders the main view

port = process.env.PORT || 3939

app.listen port
