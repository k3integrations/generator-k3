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
      desc: "Sets this as the base module intended to be shared with all app mddules"
      defaults: false

    @option 'topLevel',
      type: Boolean
      required: false
      desc: "Sets this as the top level module that is included in the index page and includes all submodules"
      defaults: false


  writing: ->
    @moduleName         = @_.classify @_.underscored @moduleName
    @scriptsPath        = "#{@config.get('appPath')}/scripts/"
    @modulePath         = @scriptsPath + @_.underscored @moduleName
    @appName            = @config.get 'appName'
    @topLevelModuleName = @config.get 'topLevelModuleName'
    @sharedModuleName   = @config.get 'sharedModuleName'
    @mkdir @scriptsPath
    @mkdir @modulePath unless @options.topLevel

    templateName = switch
      when @options.shared then "shared.coffee"
      when @options.topLevel then "top_module.coffee"
      else "module.coffee"

    @template templateName, @scriptsPath + "/#{@_.underscored @moduleName}.coffee"

  end: ->
    unless @options.topLevel
      newModuleLine = "  '#{@topLevelModuleName}.#{@moduleName}',"
      @insertLine @scriptsPath + @_.underscored(@topLevelModuleName) + ".coffee",
        newModuleLine



module.exports =  ModuleGenerator
