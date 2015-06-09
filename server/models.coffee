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
api_key = '02a69f77-4077-4511-857a-fc4cdf47cb49'
# required library
Client = require('node-rest-client').Client
client = new Client()
mongo = require('mongodb').MongoClient

Irelia = require 'irelia'
api = new Irelia
  secure: true
  host: 'na.api.pvp.net'
  path: '/api/lol/'
  key: api_key
  debug: false
Promise = require 'promise'
Q = require 'q'
_ = require 'lodash'

# static api path
championStatic =
  'https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion/'
matchAPI =
  'https://global.api.pvp.net/api/lol/na/v2.2/match/'


# creates module for handling requests
module.exports = () ->
  self = { }

  # connect mongodb database
  self.connectDB = (url) ->
    promise = new Promise (resolve, reject) ->
      mongo.connect url, (error, db) ->
        if error
          reject error
        else
          resolve db
    return promise

  # insert to redis
  self.insertRedis = (client, data, key) ->
    promise = new Promise (resolve, reject) ->
      client.set key, JSON.stringify(data), (error, reply) ->
        if error
          reject error
        else
          resolve reply

  # lookup records
  self.lookup = (collection, key) ->
    promise = new Promise (resolve, reject) ->
      collection.findOne name: {$regex: new RegExp("^" + key.toLowerCase(), "i")}, (err, doc) ->
        if err
          reject err
        else
          resolve doc

  # insert to collection
  self.insert = (collection, data) ->
    promise = new Promise (resolve, reject) ->
      collection.insert data, (error, docs) ->
        if error
          reject error
        else
          resolve docs

  # remove post from collection
  self.remove = (collection, key) ->
    promise = new Promise (resolve, reject) ->
      collection.remove name: {$regex: new RegExp("^" + key.toLowerCase(), "i")}, (err, result) ->
        if err
          reject err
        else
          resolve collection


  # get summoner information by name
  self.getSummonerByName = (name) ->

    promise = new Promise (resolve, reject) ->
      api.getSummonerByName 'na', name, (error, result) ->
        if error
          reject error
        else
          resolve result
    return promise
  # get recent games by summoner id
  self.getRecentGames = (id) ->
    promise = new Promise (resolve, reject) ->
      api.getRecentGamesBySummonerId 'na', id, (error, result) ->
        if error
          reject error
        else
          resolve result
    return promise

  # get summary stat
  self.getSummary = (id) ->
    promise = new Promise (resolve, reject) ->
      api.getSummaryStatsBySummonerId 'na', id, (error, result) ->
        if error
          reject error
        else
          resolve result
    return promise

  # get summoner by id
  self.getSummonerById = (id) ->
    promise = new Promise (resolve, reject) ->
      api.getSummonerBySummonerId 'na', id, (error, result) ->
        if error
          reject error
        else
          resolve result
    return promise
  # get summoners by id
  self.getSummonersById = (ids) ->
    promise = new Promise (resolve, reject) ->
      api.getSummonersBySummonerIds 'na', ids, (error, result) ->
        if error
          reject error
        else
          resolve result
    return promise
  # get champions
  self.getChampions = () ->
    promise = new Promise (resolve, reject) ->
      api.getChampions 'na', (error, result) ->
        if error
          reject error
        else
          resolve result
    return promise
  # get champion picture
  self.getChampionInfo = (id) ->
    promise = new Promise (resolve, reject) ->
      client.get "#{championStatic}#{id}?api_key=#{api_key}", (data, res) ->
        if data == undefined
          reject res
        else
          resolve data
    return promise

  # get match info
  self.getMatchInfo = (id) ->
    promise = new Promise (resolve, reject) ->
      client.get "#{matchAPI}#{id}?api_key=#{api_key}", (data, res) ->
        if data == undefined
          reject res
        else
          resolve data
    return promise

  # calculate op score
  self.calculateOPS = (data) ->
    # calculate ratio between dealt and taken
    ratioPackage =
      damageRatio: data.stats.totalDamageDealt / data.stats.totalDamageTaken
      kda: data.stats.championsKilled / data.stats.numDeaths
      damageUntilDeath: data.stats.totalDamageDealt / data.stats.numDeaths
      damageUntilKill: data.stats.totalDamageTaken / data.stats.championsKilled
      turretModifier: data.stats.turretsKilled / (data.stats.timePlayed / 60)

    Object.keys(ratioPackage).forEach (key) ->
      if isNaN ratioPackage[key]
        ratioPackage[key] = 0.055
    damageMultifier = ratioPackage.kda * ratioPackage.damageRatio *
    ratioPackage.turretModifier
    console.log "dmg mult: " + damageMultifier

    # calculate actual score
    wardScore = (data.stats.wardPlaced/10) * 0.2
    dmgScore = (data.stats.totalDamageDealt / data.stats.totalDamageTaken)*0.3*
    damageMultifier
    goldScore = (data.stats.goldEarned / data.stats.goldSpent) * 0.1
    creepScore = ((data.stats.minionsKilled / (data.stats.timePlayed / 60)) / 6) * 0.4


    # adjusting them to average if NaN
    if isNaN wardScore
      wardScore = 0.035
    if isNaN dmgScore
      wardScore = 0.3 * damageMultifier
    if isNaN goldScore
      wardScore = 0.109
    if isNaN creepScore
      wardScore = 0.16667


    console.log '#################'
    console.log "#{wardScore}"
    console.log "#{dmgScore}}"
    console.log "#{goldScore}"
    console.log "#{creepScore}"
    console.log '#################'

    # calculate fnal score
    finalScore1 = wardScore + dmgScore + goldScore + creepScore
    if finalScore1 < 1
      finalScore1 = finalScore1 * 100
    else
      # adjust final score if over 1
      ipScore = (data.ipEarned / 144) * 0.1
      console.log "before adjust: #{finalScore1}"
      score = (finalScore1 / Math.ceil(finalScore1)) * 0.9
      console.log "ipScore #{ipScore} score #{score}"
      finalScore1 = (ipScore + score) * 100


    console.log finalScore1

    return finalScore1

  return self
