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


  writing: ->
    @scriptsPath  = "#{@appPath}/scripts"
    @fileName     = @_fileName @moduleName
    @modulePath   = "#{@scriptsPath}/#{@fileName}"
    @mkdir @scriptsPath
    @dest.write "#{@modulePath}/.gitkeep", ''

    templateName = switch
      when @options.shared    then 'shared.coffee'
      when @options.topLevel  then 'top_module.coffee'
      else                         'module.coffee'

    @isWireframe = @options.isWireframe
    @template templateName, "#{@scriptsPath}/#{@fileName}.coffee"

  end: ->
    unless @options.topLevel
      newModuleLine = "  '#{@topLevelModuleName}.#{@moduleName}'"
      @insertLine "#{@scriptsPath}/#{@_.underscored @topLevelModuleName}.coffee",
        newModuleLine
      @insertLine "#{@scriptsPath}/#{@_fileName @wireModuleName}.coffee",
        newModuleLine


  _fileName: (name) ->
    @_.underscored(name).replace('.', '-')


module.exports =  ModuleGenerator
