###
 # I'M OP
 # https://github.com/r1cebank/imop
 # Copyright (c) 2015 Siyuan Gao
 # Licensed under the MIT license
###

module.exports = () ->
  # init object
  self = { }

  self.root = (req, res) ->
    res.render 'index'

  self.key = (req, res) ->
    res.send '997c3ed4-8103-481c-8cec-42e688efd5c5'

  # return this object
  return self
