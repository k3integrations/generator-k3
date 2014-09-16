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
        @angularModules =
          animateModule  : hasMod 'animateModule'
          cookiesModule  : hasMod 'cookiesModule'
          resourceModule : hasMod 'resourceModule'
          sanitizeModule : hasMod 'sanitizeModule'
          touchModule    : hasMod 'touchModule'
        done()

  writing:
    saveConfig: ->
      configs =
        appName             : @appName
        sharedModuleName    : @answers.sharedModuleName
        topLevelModuleName  : @answers.topLevelModuleName
        wireModuleName      : "#{@answers.topLevelModuleName}.Wire"
        appPath             : @options.appPath
        testPath            : @options.testPath
        directiveNamespace  : @answers.directiveNamespace
      @config.set configs

      # avoid the debounce tick for auto-saving from @config.set
      @config.forceSave()

      # load our config settings as local properties
      @_.extend @, configs

    createTopLevelModule: ->
      @composeWith "k3:module",
        arguments: [@topLevelModuleName]
        options: topLevel: true

    createWireModule: ->
      @composeWith "k3:module",
        arguments: [@wireModuleName]
        options: topLevel: true, isWireframe: true

    createSharedModule: ->
      sharedOptions = @_.extend {}, @angularModules,
        shared: true

      @composeWith "k3:module",
        arguments: [@sharedModuleName]
        options: sharedOptions

    createMainModule: ->
      @composeWith "k3:module",
        arguments: [@answers.firstModuleName]

    bower: ->
      @template '_bower.json' , 'bower.json'
      @template '_bowerrc'    , '.bowerrc'

    nodeModules: ->
      @template '_package.json' , 'package.json'

    gulp: ->
      @template '_gulpfile.js'    , 'gulpfile.js'
      @template '_gulpfile.coffee', 'gulpfile.coffee'

    git: ->
      @template '_gitignore', '.gitignore'

    scripts: ->
      scriptsPath = "#{@appPath}/scripts"
      @template '_holderJSDirective.coffee' , "#{scriptsPath}/#{@_.underscored @sharedModuleName}/directives/holder.coffee"

    html: ->
      partialsPath = "#{@appPath}/partials"
      @template 'index.html'          , "#{@appPath}/index.html"
      @template '_home.jade'          , "#{partialsPath}/home.jade"
      @template '_header.jade'        , "#{partialsPath}/header.jade"
      @template '_header-mobile.jade' , "#{partialsPath}/header-mobile.jade"
      @template '_footer.jade'        , "#{partialsPath}/footer.jade"


  install: -> @installDependencies()


  end:
    karma: ->
      enabledComponents = []

      if @angularModules.animateModule
        enabledComponents.push 'angular-animate/angular-animate.js'
      if @angularModules.cookiesModule
        enabledComponents.push 'angular-cookies/angular-cookies.js'
      if @angularModules.resourceModule
        enabledComponents.push 'angular-resource/angular-resource.js'
      if @angularModules.sanitizeModule
        enabledComponents.push 'angular-sanitize/angular-sanitize.js'
      if @angularModules.touchModule
        enabledComponents.push 'angular-touch/angular-touch.js'

      enabledComponents = [
        'jquery/dist/jquery.js'
        'angular/angular.js'
        'angular-mocks/angular-mocks.js'
      ].concat(enabledComponents).join ','

      @log '\n\n'
      @composeWith('karma:app', {
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
      } , {
        local: require.resolve('generator-karma')
      })

    injectDependencies: ->
      done = @async()
      @log '\n\n'
      @spawnCommand('gulp', ['wiredep', 'wireup'])
      .on 'error', =>
        @log chalk.red.bold """
          Please ensure you have gulp installed then run:

          gulp wiredep
          gulp wireup
        """
      .on 'exit', =>
        @log """
          We have just run `npm install & bower install` for you, and injected
          your front end dependencies into your source code by running:

          #{chalk.yellow.bold 'gulp wiredep'}
          #{chalk.yellow.bold 'gulp wireup'}

          In the future this will be taken care of by `gulp watch` while your app is running.

          Also, remember you can configure karma processors. For example you may want sourcemaps.
          For information checkout the coffeescript example at https://github.com/karma-runner/karma-coffee-preprocessor
        """
        done()

    goodbye: ->
      @log """

          #{chalk.blue 'As you where, gents!'}
          #{chalk.yellow 'Run `gulp watch` to get everything up and running!'}
      """


  # Private
  _classify: (name)->
    @_.classify @_.underscored name



module.exports = AppGenerator
