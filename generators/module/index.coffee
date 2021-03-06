'use strict'

K3Generator  = require('../generator')

class ModuleGenerator extends K3Generator
  constructor: ->
    super

    @argument 'moduleName',
      type: String
      required: true
      desc: "Name for new module"

    @option 'shared',
      type: Boolean
      required: false
      desc: "Sets this as the base module intended to be shared with all app modules"
      defaults: false

    @option 'topLevel',
      type: Boolean
      required: false
      desc: "Sets this as the top level module that is included in the index page and includes all submodules"
      defaults: false

    @option 'isWireframe',
      type: Boolean
      required: false
      desc: 'Sets this as the module for the wireframe version of the app.'
      defaults: false

    @option 'animateModule',
      type: Boolean
      required: false
      defaults: false

    @option 'cookiesModule',
      type: Boolean
      required: false
      defaults: false

    @option 'resourceModule',
      type: Boolean
      required: false
      defaults: false

    @option 'sanitizeModule',
      type: Boolean
      required: false
      defaults: false

    @option 'touchModule',
      type: Boolean
      required: false
      defaults: false


  writing: ->
    @scriptsPath  = "#{@appPath}/scripts"
    @modulePath   = "#{@scriptsPath}/#{@dasherize @moduleName}"
    @mkdir @scriptsPath

    templateName = switch
      when @options.shared    then 'shared.coffee'
      when @options.topLevel  then 'topModule.coffee'
      else                         'module.coffee'

    @isWireframe = @options.isWireframe
    @template templateName, "#{@modulePath}/main.coffee"

  end: ->
    unless @options.topLevel
      newModuleLine = "  '#{@topLevelModuleName}.#{@moduleName}'"
      @insertLine "#{@scriptsPath}/#{@dasherize @topLevelModuleName}/main.coffee",
        newModuleLine
      @insertLine "#{@scriptsPath}/#{@dasherize @wireModuleName}/main.coffee",
        newModuleLine


module.exports =  ModuleGenerator
