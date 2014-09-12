'use strict'

K3NamedGenerator = require "../named_generator"

class DirectiveGenerator extends K3NamedGenerator
  constructor: ->
    @componentName = "directive"
    super


  prompting: ->
    super


  writing: ->
    @namespacedCameledName = @_namespaced(@name)
    super

  _namespaced: (name)->
    ns = @directiveNamespace || ''
    @_.camelize(ns + @name)


module.exports =  DirectiveGenerator
