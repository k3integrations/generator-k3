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
    @namespacedCameledName = @_namespacedName
    super

  _namespacedName: ->
    @camelize "#{@directiveNamespace || ''}#{@dasherize(@name, false).classify()}"


module.exports =  DirectiveGenerator
