'use strict'

ServiceGeneratorBase = require "../service_generator_base"

class FactoryGenerator extends ServiceGeneratorBase
  constructor: ->
    @componentName = "factory"
    super


  prompting: ->
    super


  writing: ->
    super

module.exports =  FactoryGenerator
