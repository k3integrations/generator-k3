'use strict'

chalk   = require 'chalk'
path    = require 'path'
yeoman  = require 'yeoman-generator'

class AppGenerator extends yeoman.generators.Base
  constructor: ->
    super

    appNameFromPath = @_classify path.basename process.cwd()

    @argument 'appName',
      type: String
      required: false
      desc: "Name for application"
      defaults: @config.get('appName') || appNameFromPath

    @option 'appPath',
      type: String
      required: false
      desc: "The location of your webapp"
      defaults: "app"

    @option 'testPath',
      type: String
      required: false
      desc: "The location of your tests"
      defaults: "test"



  prompting:
    modules: ->
      done = @async()

      @prompt [
          type    : "input"
          name    : "topLevelModuleName"
          message : "What is the name of your top level module (will also add a [name].Wire version for wireframing):"
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
          default : "Home"
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
        hasMod = (mod) -> ~answers.modules.indexOf(mod)
        @animateModule  = hasMod 'animateModule'
        @cookiesModule  = hasMod 'cookiesModule'
        @resourceModule = hasMod 'resourceModule'
        @routeModule    = hasMod 'routeModule'
        @sanitizeModule = hasMod 'sanitizeModule'
        @touchModule    = hasMod 'touchModule'
        done()

  saveConfig: ->
    @config.set 'appName',  @appName
    @config.set 'sharedModuleName',  @_classify @answers.sharedModuleName
    @topLevelModuleName = @config.set 'topLevelModuleName', @answers.topLevelModuleName
    @wireModuleName     = @config.set 'wireModuleName', "#{@topLevelModuleName}.Wire"
    @appPath            = @config.set 'appPath',  @options.appPath
    @testPath           = @config.set 'testPath',  @options.testPath
    @directiveNamespace = @config.set 'directiveNamespace',  @answers.directiveNamespace


  writing:
    createTopLevelModule: ->
      @composeWith "k3:module",
        arguments: [@topLevelModuleName]
        options: topLevel: true

    createWireModule: ->
      @composeWith "k3:module",
        arguments: [@wireModuleName]
        options: topLevel: true

    createSharedModule: ->
      @composeWith "k3:module",
        arguments: [@config.get 'sharedModuleName']
        options: shared: true

    createMainModule: ->
      @composeWith "k3:module",
        arguments: [@answers.firstModuleName]

    packageFiles: ->
      @template '_bower.json'         , 'bower.json'
      @template '_bowerrc'            , '.bowerrc'
      @template '_package.json'       , 'package.json'
      @template '_gulpfile.js'        , 'gulpfile.js'
      @template '_gulpfile.coffee'    , 'gulpfile.coffee'
      @template '_gitignore'          , '.gitignore'
      @template 'index.html'          , @appPath + '/index.html'
      @template '_header.jade'        , @appPath + '/partials/header.jade'
      @template '_header-mobile.jade' , @appPath + '/partials/header-mobile.jade'
      @template '_footer.jade'        , @appPath + '/partials/footer.jade'


  install: ->
    dependencies: -> @installDependencies()

    karma: ->
      enabledComponents = []

      if @animateModule
        enabledComponents.push 'angular-animate/angular-animate.js'
      if @cookiesModule
        enabledComponents.push 'angular-cookies/angular-cookies.js'
      if @resourceModule
        enabledComponents.push 'angular-resource/angular-resource.js'
      if @routeModule
        enabledComponents.push 'angular-route/angular-route.js'
      if @sanitizeModule
        enabledComponents.push 'angular-sanitize/angular-sanitize.js'
      if @touchModule
        enabledComponents.push 'angular-touch/angular-touch.js'

      enabledComponents = [
        'jquery/dist/jquery.js'
        'angular/angular.js'
        'angular-mocks/angular-mocks.js'
      ].concat(enabledComponents).join ','

      @composeWith 'karma:app',
        options:
          'base-path': '../../'
          'config-path': "#{@testPath}/"
          'browsers': 'Chrome'
          'coffee': true
          # 'travis': true
          'skip-install': true
          'test-framework': 'mocha'
          'app-files': "#{@appPath}/scripts/**/*.coffee"
          'bower-components-path': "#{@appPath}/bower_components"
          'bower-components': enabledComponents
          'test-files': "#{@testPath}/**/*_spec.coffee"

    injectDependencies: ->
      @spawnCommand('gulp', ['wiredep', 'wireup']).on 'exit', =>
        @log """

          After running `npm install & bower install`, inject your front end dependencies
          into your source code by running:

          #{chalk.yellow.bold 'gulp wiredep'}
          #{chalk.yellow.bold 'gulp wireup'}

          In the future this will be taken care of by `gulp watch` while your app is running.

          Also, remember you can configure karma processors. For example you may want sourcemaps.
          For information checkout the coffeescript example at https://github.com/karma-runner/karma-coffee-preprocessor
        """


  end: ->
    @log """

      As you where, gents!
      Run `gulp watch` to get everything up and running!
    """


  #Private
  _classify: (name)->
    @_.classify @_.underscored name



module.exports = AppGenerator
