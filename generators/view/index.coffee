'use strict'

K3NamedGenerator = require "../named_generator"

class ViewGenerator extends K3NamedGenerator
  constructor: ->
    @componentName = "view"
    super


  prompting: ->
    super


  writing: ->
    super


  _writeSourceAndSpec: ->
    @template "#{@componentName}.jade", "#{@appPath}/scripts/#{@moduleSlug}/#{@componentName}s/#{@componentSlug}.jade"


module.exports =  ViewGenerator
