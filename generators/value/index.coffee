'use strict'

ServiceGeneratorBase = require "../service_generator_base"

class ValueGenerator extends ServiceGeneratorBase
  constructor: ->
    @componentName = "value"
    super


  prompting: ->
    super


  writing: ->
    super

module.exports =  ValueGenerator
