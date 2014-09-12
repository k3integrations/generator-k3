'use strict'

K3NamedGenerator = require "./named_generator"

class ServiceGeneratorBase extends K3NamedGenerator
  constructor: ->
    @componentName ||= "service"
    super


  prompting: ->
    super


  writing: ->
    super


  _writeSourceAndSpec: ->
    @template "#{@componentName}.coffee", "#{@appPath}/scripts/#{@moduleSlug}/services/#{@componentSlug}.coffee"
    @template "../../service/templates/service_spec.coffee", "#{@testPath}/#{@moduleSlug}/services/#{@componentSlug}_spec.coffee"


module.exports =  ServiceGeneratorBase
