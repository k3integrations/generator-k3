yeoman  = require 'yeoman-generator'
chalk   = require 'chalk'

class K3Generator extends yeoman.generators.Base
  constructor: ->
    super
    @_.extend @, @config.getAll()


  insertLine: (path, insert, hook="  #=== yeoman hook ===#")->
    file = @readFileAsString path

    firstLine = insert.split('\n')[0]

    if file.indexOf(firstLine) == -1
      @writeFileFromString file.replace(hook, insert + '\n' + hook), path


  chalk: chalk


  # Define dasherize the way we would expect it to work
  dasherize: (string, stringify=true)->
    str = @_(string.replace('.', '')).dasherize().trim('-')
    if stringify then str.toString() else str

  # And define the inverse here, just for consistency
  classify: (string)-> @_(string).classify().toString()

  camelize: (string)-> @dasherize(string, false).camelize().toString()



module.exports = K3Generator
