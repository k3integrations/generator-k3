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
    @noSpec = true
    super
    @log @chalk.underline.yellow "No spec template currently available for decorator"


module.exports =  DecoratorGenerator
