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
    @fileName     = @_fileName @moduleName
    @modulePath   = "#{@scriptsPath}/#{@fileName}"
    @mkdir @scriptsPath
    @dest.write "#{@modulePath}/.gitkeep", ''

    templateName = switch
      when @options.shared    then 'shared.coffee'
      when @options.topLevel  then 'topModule.coffee'
      else                         'module.coffee'

    @isWireframe = @options.isWireframe
    @template templateName, "#{@scriptsPath}/#{@camelize @moduleName}.coffee"

  end: ->
    unless @options.topLevel
      newModuleLine = "  '#{@topLevelModuleName}.#{@moduleName}'"
      @insertLine "#{@scriptsPath}/#{@camelize @topLevelModuleName}.coffee",
        newModuleLine
      @insertLine "#{@scriptsPath}/#{@camelize @wireModuleName}.coffee",
        newModuleLine


  _fileName: (name) -> @dasherize(name)


module.exports =  ModuleGenerator
