K3Generator = require "./generator"

class K3NamedGenerator extends K3Generator
  constructor: ->
    super

    @argument 'name',
      required: true
      desc    : @nameArgDesc || "#{@_.capitalize @componentName} name"

    @name ?= ""
    @_parseName()
    @cameledName    = @camelize(@name)
    @classedName    = @classify(@name)


  prompting: ->
    unless @moduleName?
      done        = @async()
      @modules    = {}
      modulePaths = @expand("#{@appPath}/scripts/*/")

      for path in modulePaths
        nameParts = path.split('/')
        dirName   = nameParts.slice(-2)[0]
        modName   = dirName.replace("#{@dasherize @topLevelModuleName}-", '')
        @modules[@classify modName] = dirName

      return @log.error "No existing modules" unless @_.keys(@modules).length

      @prompt
        type    : 'list'
        name    : 'moduleName'
        message : 'Which module does it belong in?'
        choices : @_.map @modules, (dir, mod) -> "#{mod} (#{dir})"
      , (answers) =>
        @moduleName = answers.moduleName.replace /\s(.*)$/, ''
        @moduleSlug = @modules[@moduleName]
        done()


  writing: ->
    @scriptAppName  = "#{@topLevelModuleName}.#{@moduleName}"
    @componentSlug  = @cameledName
    @_writeSourceAndSpec()


  _writeSourceAndSpec: ->
    @template "#{@componentName}.coffee", "#{@appPath}/scripts/#{@moduleSlug}/#{@componentName}s/#{@componentSlug}.coffee"
    @template "#{@componentName}Spec.coffee", "#{@testPath}/#{@moduleSlug}/#{@componentName}s/#{@componentSlug}Spec.coffee"


  _parseName: ->
    nameParts = @name.split(/\.|\:/)
    if nameParts.length > 1
      @moduleName   = nameParts[0]
      @name         = nameParts[nameParts.length - 1]


module.exports = K3NamedGenerator
