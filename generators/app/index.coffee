'use strict'

chalk       = require 'chalk'
path        = require 'path'
yeoman      = require 'yeoman-generator'
K3Generator = require "../generator"

class AppGenerator extends K3Generator
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

    setupRails: ->
      layoutPath = "../app/views/layouts/application.html.erb"
      if @fs.exists layoutPath
        console.log "Replacing NG_APP in application.html.erb"
        file = @readFileAsString layoutPath
        file = file.replace /\{\{NG_APP\}\}/g, @topLevelModuleName
        @writeFileFromString file, layoutPath

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

    karma: ->
      @template '_karma.conf.coffee', 'karma.conf.coffee'

    scripts: ->
      scriptsPath   = "#{@appPath}/scripts"
      wfPath        = "#{scriptsPath}/#{@dasherize @wireModuleName}"
      sharePath     = "#{scriptsPath}/#{@dasherize @sharedModuleName}"
      shareSpecPath = "#{@testPath}/#{@dasherize @sharedModuleName}"

      @template 'scripts/_jquery.parseParams.coffee'  , "#{wfPath}/jquery.parseParams.coffee"
      @template 'scripts/_mockModels.coffee'          , "#{wfPath}/services/mockModels.coffee"
      @template 'scripts/_mocks.coffee'               , "#{wfPath}/services/mocks.coffee"
      @template 'scripts/_exitOffCanvas.coffee'       , "#{sharePath}/directives/exitOffCanvas.coffee"
      @template 'scripts/_holderJSDirective.coffee'   , "#{sharePath}/directives/holder.coffee"
      @template 'scripts/_markWhenTop.coffee'         , "#{sharePath}/directives/markWhenTop.coffee"
      @template 'scripts/_stopClickPropagation.coffee', "#{sharePath}/directives/stopClickPropagation.coffee"
      @template 'scripts/_truncateFilter.coffee'      , "#{sharePath}/filters/truncate.coffee"
      @template 'scripts/_truncateFilterSpec.coffee'  , "#{shareSpecPath}/filters/truncateSpec.coffee"
      @template 'scripts/_pluralizeFilter.coffee'     , "#{sharePath}/filters/pluralize.coffee"
      @template 'scripts/_pluralizeFilterSpec.coffee' , "#{shareSpecPath}/filters/pluralizeSpec.coffee"

    styles: ->
      stylePath = "#{@appPath}/styles"
      @template 'styles/_main.scss'           , "#{stylePath}/main.scss"
      @template 'styles/_wireframing.scss'    , "#{stylePath}/_wireframing.scss"
      @template 'styles/_util.scss'           , "#{stylePath}/_util.scss"
      @template 'styles/_reveal-modal-overrides.scss' , "#{stylePath}/_reveal-modal-overrides.scss"
      @template 'styles/_site-navigation.scss', "#{stylePath}/_site-navigation.scss"
      @template 'styles/_site-header.scss'    , "#{stylePath}/_site-header.scss"
      @template 'styles/_site-footer.scss'    , "#{stylePath}/_site-footer.scss"
      @template 'styles/_home.scss'           , "#{stylePath}/_home.scss"
      @template 'styles/_login.scss'          , "#{stylePath}/_login.scss"

    html: ->
      @currentYear  = (new Date()).getFullYear()
      partialsPath  = "#{@appPath}/partials"
      @template 'html/index.html'         , "#{@appPath}/index.html"
      @template 'html/_home.jade'         , "#{partialsPath}/home.jade"
      @template 'html/_header.jade'       , "#{partialsPath}/header.jade"
      @template 'html/_header-mobile.jade', "#{partialsPath}/header-mobile.jade"
      @template 'html/_footer.jade'       , "#{partialsPath}/footer.jade"


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

    injectDependencies: ->
      done = @async()
      @spawnCommand('gulp', ['wiredep'])
      .on 'error', =>
        @log chalk.red.bold """
          Please ensure you have gulp installed then run:

          gulp wiredep
        """
      .on 'exit', =>
        @log """


          We have just run `npm install & bower install` for you, and injected
          your front end dependencies into your source code by running:

          #{chalk.yellow.bold 'gulp wiredep'}

          In the future this will be taken care of by `gulp watch` while your app is running.
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
