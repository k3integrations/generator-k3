'use strict'

ServiceGeneratorBase = require "../service_generator_base"

class ConstantGenerator extends ServiceGeneratorBase
  constructor: ->
    @componentName = "constant"
    super


  prompting: ->
    super


  writing: ->
    super

module.exports =  ConstantGenerator
