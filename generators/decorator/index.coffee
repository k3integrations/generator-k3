'use strict'

K3NamedGenerator = require "../named_generator"

class DecoratorGenerator extends K3NamedGenerator
  constructor: ->
    @componentName = "decorator"
    @nameArgDesc   = "The name of the service you want to decorate"
    super


  prompting: ->
    super


  writing: ->
    super


module.exports =  DecoratorGenerator
