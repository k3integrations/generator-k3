K3Generator = require "./generator"

class K3NamedGenerator extends K3Generator
  constructor: ->
    super

    @argument 'name',
      required: true
      desc    : @nameArgDesc || "#{@_.capitalize @componentName} name"

    @name ?= ""
    @_parseName()
    @cameledName    = @_.camelize(@name)
    @classedName    = @_.classify(@name)
    @name           = @_.classify @_.underscored @name


  prompting: ->
    unless @moduleName?
      done = @async()
      modules = []
      modulePaths = @expand("#{@appPath}/scripts/*/")

      for path in modulePaths
        nameParts = path.split('/')
        modules.push @_.classify nameParts[nameParts.length - 2]

      return @log.error "No existing modules" unless modules.length

      @prompt
        type: 'list'
        name: 'moduleName'
        message: 'Which module does it belong in?'
        choices: modules
      , (answers)=>
        @moduleName =  answers.moduleName
        done()


  writing: ->
    @moduleName = @_.classify @_.underscored @moduleName
    @scriptAppName  = "#{@topLevelModuleName}.#{@moduleName}"
    @moduleSlug     = @_.underscored @moduleName
    @componentSlug  = @_.underscored @name
    @_writeSourceAndSpec()


  _writeSourceAndSpec: ->
    @template "#{@componentName}.coffee", "#{@appPath}/scripts/#{@moduleSlug}/#{@componentName}s/#{@componentSlug}.coffee"
    @template "#{@componentName}_spec.coffee", "#{@testPath}/#{@moduleSlug}/#{@componentName}s/#{@componentSlug}_spec.coffee"


  _parseName: ->
    nameParts = @name.split(/\.|\:/)
    if nameParts.length > 1
      @moduleName   = nameParts[0]
      @name         = nameParts[nameParts.length - 1]


module.exports = K3NamedGenerator
