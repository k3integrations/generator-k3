'use strict'

K3NamedGenerator = require "../named_generator"

class DirectiveGenerator extends K3NamedGenerator
  constructor: ->
    @nameArgDesc = "Directive name, will be prefixed with application namespace"
    @componentName = "directive"
    super


  prompting: ->
    super


  writing: ->
    @namespacedCameledName = @_namespaced(@name)
    super

  _namespaced: (name)->
    ns = @directiveNamespace || ''
    @camelize(ns + @dasherize(@name, false).classify())


module.exports =  DirectiveGenerator
