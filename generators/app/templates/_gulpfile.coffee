'use strict'


gulp  = require 'gulp'
# load plugins
$     = require('gulp-load-plugins')()
#For direct invocation (ie, not through gulp-notify)
path     = require('path')
notifier = require('node-notifier')
mainBowerFiles = require('main-bower-files');
_        = require('lodash')

appConfig       = require('./.yo-rc.json')['generator-k3']
appConfig.app   = appConfig.appPath || require('./bower.json').appPath || 'app'
appConfig.dist  = 'dist'

####
# Notifications config
_notificationsEnabled = false
notificationsEnabled  = (file)->
  _notificationsEnabled
error_badge   = path.join(__dirname, 'node_modules', 'gulp-notify',
                          'assets', 'gulp-error.png')
regular_badge = path.join(__dirname, 'node_modules', 'gulp-notify',
                          'assets', 'gulp.png')
notificationDefaults = regular: icon: regular_badge
notify = (options)->
  notifier.notify _.extend({}, notificationDefaults.regular, options)
#
####

cleaned = false

gulp.task 'styles', ['clean'], ->
  gulp.src "#{appConfig.app}/styles/**/*.scss"
    .pipe $.plumber
      errorHandler: $.notify.onError("Sass Error: <%%= error.message %>")
    .pipe $.sourcemaps.init()
    .pipe $.sass
      outputStyle: 'expanded',
      precision: 10
    .pipe $.autoprefixer('last 1 version')
    .pipe $.sourcemaps.write('./maps')
    .pipe gulp.dest('.tmp/styles')
    .pipe $.size()


gulp.task 'scripts', ->
  gulp.src [
      "#{appConfig.app}/scripts/main.js"
      "#{appConfig.app}/scripts/**/*.js"
      "!#{appConfig.app}/scripts/vendor/**/*.js"
    ]
    .pipe $.plumber
      errorHander: $.notify.onError("Script Error: <%%= error.message %>")
    .pipe $.jshint()
    .pipe $.jshint.reporter(require 'jshint-stylish')
    .pipe $.size()


gulp.task 'coffee', ['clean'], ->
  gulp.src "#{appConfig.app}/scripts/**/*.coffee"
    .pipe $.cached('coffee')
    .pipe $.plumber
      errorHandler: $.notify.onError("Coffee Error: <%%= error.message %>")
    .pipe $.sourcemaps.init()
    .pipe $.coffee()
    .pipe $.sourcemaps.write('./maps')
    .pipe gulp.dest('.tmp/scripts/')
    .pipe $.size()

templates = (dest)->
  gulp.src "#{appConfig.app}/partials/**/*.jade"
    .pipe $.plumber
      errorHandler: $.notify.onError("Jade Error: <%%= error.message %>")
    .pipe $.jade()
    .pipe gulp.dest(dest)

gulp.task 'templates',             ['clean'], ->
  templates '.tmp/partials/'

gulp.task 'templates-build',       ['clean'], ->
  templates "#{appConfig.dist}/partials"

gulp.task 'templates-build-rails', ['clean'], ->
  templates '../public/partials'

html = (dest, src=[], includeIndex=true)->
  jsFilter        = $.filter '**/*.js'
  cssFilter       = $.filter '**/*.css'
  noErbFilter     = $.filter '!{../../,}**/*.erb'
  noIndexFilter   = $.filter '!index.html'
  noBowerFilter   = $.filter '!bower_components/**/*.html'
  assets          = $.useref.assets searchPath: "{.tmp,#{appConfig.app}}"
  srcHtml         = ["#{appConfig.app}/**/*.html", ".tmp/**/*.html"]

  srcHtml.unshift s for s in src

  htmlStream = gulp.src srcHtml, base: appConfig.app
    .pipe $.if !includeIndex, noIndexFilter
    .pipe noBowerFilter
    .pipe assets
    .pipe jsFilter
    .pipe $.ngAnnotate()
    .pipe $.uglify()
    .pipe jsFilter.restore()
    .pipe cssFilter
    .pipe $.replace(
      /url\(['"]?(?!data:|\.\.\/|\/|\.\/)[^'")]*?([^\/'")]+)['"]?\)/g,
      "url('/vendor/$1')")
    .pipe $.csso()
    .pipe cssFilter.restore()
    .pipe $.rev()
    .pipe assets.restore()
    .pipe $.if !includeIndex, noErbFilter
    .pipe $.useref()
    .pipe $.revReplace()
    .pipe gulp.dest(dest)
    .pipe $.size()
    .pipe $.if !includeIndex, noErbFilter.restore()


gulp.task 'html', ['clean', 'templates-build', 'styles', 'coffee', 'scripts'], ->
  html appConfig.dist


gulp.task 'rails-html', [
  'clean', 'templates-build-rails', 'styles', 'coffee', 'scripts'
], ->
  dest = '../public'
  src  = [
    '../app/views/layouts/application.html.erb'
    ##
    # Other Targets can be added here
    # '../app/views/application/_injected_admin_scripts.html.erb'
  ]
  html(dest, src, false)
    .pipe $.through('change-manifest-paths',  (file)->
      return unless file.path && file.revOrigPath
      file.path        = file.path.replace /assets\/?/, ''
      file.revOrigPath = file.revOrigPath.replace /assets\/?/, ''
      return
    )()
    .pipe $.revRailsManifest(path: 'assets/manifest.json')
    .pipe gulp.dest(dest)


images = (dest)->
  gulp.src "#{appConfig.app}/images/**/*"
    .pipe $.cache($.imagemin
      optimizationLevel : 3
      progressive       : true
      interlaced        : true
    )
    .pipe gulp.dest(dest)
    .pipe $.size()

gulp.task 'clear-cache', (done)-> $.cache.clearAll(done)

gulp.task 'images',       ['clean'], -> images("#{appConfig.dist}/images")
gulp.task 'rails-images', ['clean'], -> images("../public/images")

fonts = (dest)->
  gulp.src ["#{appConfig.app}/bower_components/**/*", "#{appConfig.app}/fonts/**/*"]
    .pipe $.filter('**/*.{eot,svg,ttf,woff}')
    .pipe $.flatten()
    .pipe gulp.dest(dest)
    .pipe $.size()

gulp.task 'fonts',       ['clean'], -> fonts("#{appConfig.dist}/fonts")
gulp.task 'rails-fonts', ['clean'], -> fonts('../public/fonts')

extras = (dest)->
  gulp.src ["#{appConfig.app}/*.*", "!#{appConfig.app}/*.html"], { dot: true }
    .pipe gulp.dest(dest)

gulp.task 'extras',       ['clean'], -> extras(appConfig.dist)
gulp.task 'rails-extras', ['clean'], -> extras('../public')

bowerFiles = (dest)->
  dest = "#{dest}/vendor"
  gulp.src mainBowerFiles(), base: "#{appConfig.app}/bower_components"
    .pipe $.filter '!**/*.{js,css,scss}'
    .pipe $.rename dirname: ''
    .pipe gulp.dest(dest)

gulp.task 'bower-files',       ['clean'], -> bowerFiles(appConfig.dist)
gulp.task 'rails-bower-files', ['clean'], -> bowerFiles('../public')
gulp.task 'static-files',      ['clean'], -> bowerFiles ".tmp"

gulp.task 'clean', ['clear-cache'], ->
  toClean = !cleaned
  cleaned = true if toClean
  cleanDirs = ['.tmp', appConfig.dist, '../public/*']
  gulp.src cleanDirs, { dot: true, read: false }
    .pipe $.if(toClean, $.rimraf(force: true))

gulp.task 'build',       ['html', 'images', 'fonts', 'extras', 'bower-files']
gulp.task 'rails-build', ['rails-images', 'rails-html', 'rails-fonts', 'rails-extras', 'rails-bower-files']

gulp.task 'default', ['build']

gulp.task 'connect', (cb)->
  connect = require 'connect'
  app     = connect()
    .use require('connect-livereload')
      port: 35729
    .use connect.static(appConfig.app)
    .use connect.static('.tmp')
    .use connect.directory(appConfig.app)

  require 'http'
    .createServer app
    .listen 9000
    .on 'listening', ->
      console.log 'Started connect web server on http://localhost:9000'
      cb()


gulp.task 'build-connect', (cb)->
  connect = require 'connect'
  app     = connect()
    .use connect.static(appConfig.dist)
  require 'http'
    .createServer app
    .listen 9000
    .on 'listening', ->
      console.log 'Started connect web server on http://localhost:9000'
      cb()


wireupSass = ->
  wireStream = require('wiredep').stream
  gulp.src "#{appConfig.app}/styles/main.scss"
    .pipe wireStream
      directory: "#{appConfig.app}/bower_components"
      devDependencies: true
    .pipe gulp.dest("#{appConfig.app}/styles")

# inject all dependencies (bower, app)
wireup = (dest, options={rails:false})->
  wireStream = require('wiredep').stream
  replace    = require('gulp-replace')
  destDir    = dest.split('/').slice(0, -1).join('/')

  filesFor = (paths)->
    #TODO: can we do this without compiling?
    gulp.src(paths, {cwd: appConfig.app})
      .pipe $.coffee()
      .pipe($.angularFilesort())

  inject = (files, name, addRootSlash = false)->
    $.inject(files,  {name: name,  addRootSlash: addRootSlash})

  wireFiles  = filesFor('scripts/!(<%= dasherize(topLevelModuleName) %>|<%= dasherize(wireModuleName) %>)/**/*.coffee')
  appFiles   = filesFor('scripts/<%= dasherize(wireModuleName) %>/**/*.coffee')
  baseFiles  = filesFor('scripts/<%= dasherize(topLevelModuleName) %>/**/*.coffee')

  stream = gulp.src(dest)
    .pipe inject(wireFiles,  'inject-wire')
    .pipe inject(appFiles,   'inject-app')
    .pipe inject(baseFiles,  'inject-base')

  stream = if options.rails
    stream.pipe wireStream
      directory: "#{appConfig.app}/bower_components"
    .pipe replace("../../../client/#{appConfig.app}/", '')
  else
    stream.pipe wireStream
      directory: "#{appConfig.app}/bower_components"
      devDependencies: true

  stream.pipe(gulp.dest(destDir))


wiredep      = -> wireup( "#{appConfig.app}/*.html" )
wiredepRailsApp = ->
  wireup( '../app/views/layouts/application.html.erb', rails: true )
wiredepRails = ->
  wiredepRailsApp()

gulp.task 'wireup-rails-application', ['coffee'], wiredepRailsApp

gulp.task 'wireupJavascriptRails', ['wireup-rails-application']
gulp.task 'wireupJavascript',      ['coffee'], wiredep
gulp.task 'wireupSass',            ['styles'],   wireupSass

gulp.task 'wiredep',       ['wireupJavascript', 'wireupSass']
gulp.task 'rails-wiredep', ['wireupJavascriptRails', 'wireupSass']

readyCount = 0
gulp.task 'livereload', ['coffee', 'styles'], (cb)->
  liveReloadables = [
    "{#{appConfig.app},.tmp}/**/*.html"        # refreshes the browser
    "{#{appConfig.app},.tmp}/styles/**/*.css"  # reloads the CSS within the current page
    "{#{appConfig.app},.tmp}/scripts/**/*.js"  # refreshes the browser
    "#{appConfig.app}/images/**/*"             # (not sure)
  ]

  # watch for changes & notify the LiveReload server
  server  = $.livereload()
  watch   = gulp.watch(liveReloadables)
  watch.on 'change', (file) -> server.changed file.path
  watch.on 'ready', ->
    if readyCount < 1
      readyCount++
      cb()

incrementalWatch = (glob, tasks, name)->
  lname = name.toLowerCase()
  gulp.watch(glob, tasks).on 'change', (event)->
    notify
      title: name
      subtitle: event.type
      message: path.relative __dirname, event.path

    if event.type == 'deleted'
      delete $.cached.caches[lname][event.path]
      $.remember.forget(lname, event.path)

watch = ->
  incrementalWatch("#{appConfig.app}/styles/**/*.scss",    ['styles'], "Sass")
  incrementalWatch("#{appConfig.app}/scripts/**/*.coffee", ['coffee'], "Coffee")
  gulp.watch "#{appConfig.app}/scripts/**/*.js",     ['scripts']
  gulp.watch "#{appConfig.app}/images/**/*",         ['images']
  gulp.watch "#{appConfig.app}/partials/**/*.jade",  ['templates']

  _notificationsEnabled = true
  notify
    title: "Gulp"
    subtitle: "Watch"
    message: "All ready to go!"


gulp.task 'serve', [
  'connect', 'templates', 'static-files', 'styles', 'coffee', 'scripts', 'wiredep'
], (cb)->
  require('opn')('http://localhost:9000')
  cb()

gulp.task 'watch', ['serve', 'livereload'], (cb)->
  gulp.watch 'bower.json', ['wiredep']
  gulp.watch('.tmp/scripts/**').on 'change', (event)->
    wiredep() if ~['added', 'deleted'].indexOf(event.type)
  watch()
  cb()

gulp.task 'dev', [
  'templates', 'static-files', 'styles', 'coffee', 'scripts', 'livereload', 'rails-wiredep'
], (cb) ->
  gulp.watch 'bower.json', ['rails-wiredep']
  gulp.watch('.tmp/scripts/**').on 'change', (event)->
    wiredepRails() if ~['added', 'deleted'].indexOf(event.type)
  watch()
  cb()
