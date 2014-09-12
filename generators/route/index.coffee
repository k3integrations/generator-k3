'use strict'

K3NamedGenerator = require "../named_generator"
path = require "path"

class RouteGenerator extends K3NamedGenerator
  constructor: ->
    @componentName = "route"
    super

    @option 'uri',
      optional : true
      desc     : "The route uri"
      defaults : '/' + @name.toLowerCase()
      type     : String


  prompting: ->
    super


  writing: ->
    super

    #FIXME: Workaround: for some reason, name is getting reset to the orignal args
    @_parseName()

    invokeArgs = "#{@moduleName}.#{@name}"
    @invoke "k3:controller",
      args: [invokeArgs]
    @invoke "k3:view",
      args: [invokeArgs]



  _writeSourceAndSpec: ->
    #FIXME: Workaround: for some reason, name is getting reset to the orignal args
    @_parseName()

    moduleUri      = @_.underscored @moduleName
    routePath      = path.join(@appPath, 'scripts', moduleUri + '.coffee')
    templName      = @_.underscored @name
    controllerName = @_.classify @_.underscored @name

    # FIXME: need to update this for ui-router instead!
    insert    = "      .when '#{@options.uri}'," + '\n' +
                "        templateUrl: '#{moduleUri}/views/#{templName}'" + '\n' +
                "        controller: '#{controllerName}Ctrl'"
    hook      = '      .otherwise'

    @insertLine routePath, insert, hook


module.exports =  RouteGenerator
