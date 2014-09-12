'use strict'

ServiceGeneratorBase = require "../service_generator_base"

class ProviderGenerator extends ServiceGeneratorBase
  constructor: ->
    @componentName = "provider"
    super


  prompting: ->
    super


  writing: ->
    super

module.exports =  ProviderGenerator
