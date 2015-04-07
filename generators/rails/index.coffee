'use strict'

# yo k3:rails MyApp [rails new args] (-m "path/to/template.rb")

# yeoman      = require "yeoman-generator"
path        = require 'path'
K3Generator = require "../generator"

class RailsGenerator extends K3Generator
  constructor: ->
    super

  writing:
    createRailsApp: ->
      railsArgs = process.argv.slice(process.argv.indexOf("k3:rails") + 1)
      railsArgs.unshift "new"
      railsArgs.push "-m"
      railsArgs.push @templatePath("template.rb")

      this.spawnCommand "rails", railsArgs

module.exports = RailsGenerator
