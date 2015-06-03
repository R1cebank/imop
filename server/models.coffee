###
 # I'M OP
 # https://github.com/r1cebank/imop
 # Copyright (c) 2015 Siyuan Gao
 # Licensed under the MIT license
###
api_key = 'b1d29328-72ca-4d03-b9e2-be254f4379d6'
# required library
Client = require('node-rest-client').Client
client = new Client()
Irelia = require 'irelia'
api = new Irelia
  secure: true
  host: 'na.api.pvp.net'
  path: '/api/lol/'
  key: api_key
  debug: false
Promise = require 'promise'
Q = require 'q'

# static api path
championStatic =
  'https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion/'


# creates module for handling requests
module.exports = () ->
  self = { }

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
    promise = promise.delay 1000
    return promise

  return self
