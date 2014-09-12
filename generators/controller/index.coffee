'use strict'

K3NamedGenerator = require "../named_generator"

class ControllerGenerator extends K3NamedGenerator
  constructor: ->
    @componentName = "controller"
    super


  prompting: ->
    super


  writing: ->
    super

module.exports =  ControllerGenerator
