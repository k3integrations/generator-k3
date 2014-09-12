yeoman  = require 'yeoman-generator'
chalk   = require 'chalk'

class K3Generator extends yeoman.generators.Base
  constructor: ->
    super
    @_.extend @, @config.getAll()
    @on 'end', =>
      console.log "Include sources"
      @spawnCommand('grunt', ['fileblocks'])

  insertLine: (path, insert, hook="  #=== yeoman hook ===#")->
    file = @readFileAsString path

    firstLine = insert.split('\n')[0]

    if file.indexOf(firstLine) == -1
      @writeFileFromString file.replace(hook, insert + '\n' + hook), path

  chalk: chalk

module.exports = K3Generator
