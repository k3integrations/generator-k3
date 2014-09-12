'use strict'

chalk   = require 'chalk'
path    = require 'path'
yeoman  = require 'yeoman-generator'

class AppGenerator extends yeoman.generators.Base
  constructor: ->
    super

    appNameFromPath = @_classify(path.basename(process.cwd()))

    @argument 'appName',
      type: String
      required: false
      desc: "Name for application"
      defaults: @config.get('appName') || appNameFromPath

    @option 'appPath',
      type: String
      required: false
      desc: "The location of your webapp"
      defaults: "public"

    @option 'testPath',
      type: String
      required: false
      desc: "The location of your tests"
      defaults: "spec/javascripts/unit"



  prompting:
    modules: ->
      @appName = @_classify(@appName)

      done = @async()

      @prompt [
          type    : "input"
          name    : "topLevelModuleName"
          message : "What is the name of your top level module:"
          default : @appName
      ,
          type    : "input"
          name    : "sharedModuleName"
          message : "What is the name of your shared module:"
          default : "Shared"
      ,
          type    : "input"
          name    : "firstModuleName"
          message : "What is the name of your first module:"
          default : "Main"
      ,
          type    : "input"
          name    : "directiveNamespace"
          message : "What namespace do you want for your directives:"
          default : @appName.replace(/[a-z]/g, '').toLowerCase() #only initials
      ]
      , (answers)=>
        @answers = answers
        done()

    askForModules: ->
      done = @async()

      prompts = [
        type: 'checkbox'
        name: 'modules'
        message: 'Which modules would you like to include?'
        choices: [
          value: 'animateModule'
          name: 'angular-animate.js'
          checked: true
        ,
          value: 'cookiesModule'
          name: 'angular-cookies.js'
          checked: true
        ,
          value: 'resourceModule'
          name: 'angular-resource.js'
          checked: true
        ,
          value: 'routeModule'
          name: 'angular-route.js'
          checked: true
        ,
          value: 'sanitizeModule'
          name: 'angular-sanitize.js'
          checked: true
        ,
          value: 'touchModule'
          name: 'angular-touch.js'
          checked: true
        ]
      ]
      @prompt prompts, (answers)=>
        hasMod = (mod) -> answers.modules.indexOf(mod) != -1
        @animateModule = hasMod('animateModule')
        @cookiesModule = hasMod('cookiesModule')
        @resourceModule = hasMod('resourceModule')
        @routeModule = hasMod('routeModule')
        @sanitizeModule = hasMod('sanitizeModule')
        @touchModule = hasMod('touchModule')
        done()

  saveConfig: ->
    @config.set 'appName',  @appName
    @config.set 'sharedModuleName',  @_classify @answers.sharedModuleName
    @topLevelModuleName = @config.set 'topLevelModuleName',  @_classify @answers.topLevelModuleName
    @appPath            = @config.set 'appPath',  @options.appPath
    @testPath           = @config.set 'testPath',  @options.testPath
    @directiveNamespace = @config.set 'directiveNamespace',  @answers.directiveNamespace


  writing:
    createTopLevelModule: ->
      @invoke "angular-k3:module",
        args: [@appName]
        options: topLevel: true

    createSharedModule: ->
      @invoke "angular-k3:module",
        args: ["shared"]
        options: shared: true

    createMainModule: ->
      @invoke "angular-k3:module",
        args: [@answers.firstModuleName]


  packageFiles: ->
    @template '_bower.json', 'bower.json'
    @template '_bowerrc', '.bowerrc'
    @template '_package.json', 'package.json'
    @template '_Gruntfile.js', 'Gruntfile.js'
    @template 'index.html', @appPath + '/index.html'


  _installKarma: ->
    enabledComponents = []

    if @animateModule
      enabledComponents.push('angular-animate/angular-animate.js');

    if @cookiesModule
      enabledComponents.push('angular-cookies/angular-cookies.js');

    if @resourceModule
      enabledComponents.push('angular-resource/angular-resource.js');

    if @routeModule
      enabledComponents.push('angular-route/angular-route.js');

    if @sanitizeModule
      enabledComponents.push('angular-sanitize/angular-sanitize.js');

    if @touchModule
      enabledComponents.push('angular-touch/angular-touch.js');

    enabledComponents = [
      'jquery/dist/jquery.js',
      'angular/angular.js',
      'angular-mocks/angular-mocks.js'
    ].concat(enabledComponents).join(',');

    @invoke 'karma:app',
      options:
        'base-path': '../../'
        'config-path': 'spec/javascripts/'
        'browsers': 'Chrome'
        'coffee': true
        'travis': true
        'skip-install': true
        'test-framework': 'mocha'
        'app-files': 'public/scripts/**/*.coffee'
        'bower-components-path': 'vendor/bower_components'
        'bower-components': enabledComponents
        'test-files': 'spec/javascripts/**/*_spec.coffee'


  _injectDependencies: (done)->
    @_installKarma()
    @spawnCommand('grunt', ['wireall']).on 'exit', =>
      @log 'After running `npm install & bower install`, inject your front end dependencies' +
        '\ninto your source code by running:' +
        '\n' +
        '\n' + chalk.yellow.bold('grunt wireall') +
        '\n Also, remember you can configure karma processors. For example you may want sourcemaps.' +
        '\n For information checkout the coffeescript example at https://github.com/karma-runner/karma-coffee-preprocessor'


  install: ->
    @installDependencies callback: =>
      @_injectDependencies()



  end: ->
    @log "As you where Gents!"


  #Private
  _classify: (name)->
    @_.classify @_.underscored name


module.exports = AppGenerator
