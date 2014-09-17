'use strict'

appConfig       = require('./.yo-rc.json')['generator-k3']
appConfig.app   = appConfig.appPath || require('./bower.json').appPath || 'app'
appConfig.dist  = 'dist'

gulp  = require 'gulp'
# load plugins
$     = require('gulp-load-plugins')()

gulp.task 'styles', ->
  gulp.src "#{appConfig.app}/styles/main.scss"
    .pipe $.rubySass
      style: 'expanded',
      precision: 10
    .on 'error', (err) ->
      console.log err.message
      @emit 'end'
    .pipe $.autoprefixer('last 1 version')
    .pipe gulp.dest('.tmp/styles')
    .pipe $.size()

gulp.task 'scripts', ->
  gulp.src ["#{appConfig.app}/scripts/main.js", "#{appConfig.app}/scripts/**/*.js"]
    .pipe $.jshint()
    .pipe $.jshint.reporter(require 'jshint-stylish')
    .pipe $.size()

coffeeFiles = null
defaultCoffeeFiles = "#{appConfig.app}/scripts/**/*.coffee"
gulp.task 'coffee', ->
  source = coffeeFiles || defaultCoffeeFiles
  gulp.src source
    .pipe $.sourcemaps.init()
    .pipe $.coffee()
    .on 'error', (err) ->
      console.log err.stack
      @emit 'end'
    .pipe $.sourcemaps.write('./maps')
    .pipe gulp.dest('.tmp/scripts/')

gulp.task 'templates', ->
  gulp.src "#{appConfig.app}/partials/**/*.jade"
    .pipe $.jade()
    .on 'error', (err) ->
      console.log err.stack
      @emit 'end'
    .pipe gulp.dest('.tmp/partials/')


html = (dest, includeIndex=true)->
  jsFilter  = $.filter '**/*.js'
  cssFilter = $.filter '**/*.css'
  noIndexFilter = $.filter '!index.html'
  noBowerFilter = $.filter '!bower_components/**/*.html'

  htmlStream = gulp.src ["#{appConfig.app}/**/*.html", '.tmp/**/*.html']
    .pipe $.useref.assets searchPath: "{.tmp,#{appConfig.app}}"
    .on 'error', (err) ->
      console.log err.stack
      @emit 'end'
    .pipe jsFilter
    # .pipe $.uglify() # FIXME: this is currently causing a JS error in the built vendor.js file :(
    .pipe jsFilter.restore()
    .pipe cssFilter
    .pipe $.csso()
    .pipe cssFilter.restore()
    .pipe $.useref.restore()
    .pipe $.useref()
    .pipe noBowerFilter

  htmlStream = htmlStream.pipe noIndexFilter unless includeIndex

  htmlStream
    .pipe gulp.dest(dest)
    .pipe $.size()


gulp.task 'html', ['templates', 'styles', 'coffee', 'scripts'], -> html(appConfig.dist)
gulp.task 'rails-html', ['templates', 'styles', 'coffee', 'scripts'], ->
  html('../public', false)

images = (dest)->
  gulp.src "#{appConfig.app}/images/**/*"
    .pipe $.cache($.imagemin
      optimizationLevel : 3
      progressive       : true
      interlaced        : true
    )
    .pipe gulp.dest(dest)
    .pipe $.size()

gulp.task 'images', -> images("#{appConfig.dist}/images")
gulp.task 'rails-images', -> images('../public/images')

fonts = (dest)->
  gulp.src "#{appConfig.app}/bower_components/**/*"
    .pipe $.filter('**/*.{eot,svg,ttf,woff}')
    .pipe $.flatten()
    .pipe gulp.dest(dest)
    .pipe $.size()

gulp.task 'fonts', -> fonts("#{appConfig.dist}/fonts")
gulp.task 'rails-fonts', -> fonts('../public/fonts')

extras = (dest)->
  gulp.src ["#{appConfig.app}/*.*", "!#{appConfig.app}/*.html"], { dot: true }
    .pipe gulp.dest(dest)

gulp.task 'extras', -> extras(appConfig.dist)
gulp.task 'rails-extras', -> extras('../public')

gulp.task 'clean', ->
  gulp.src ['.tmp', appConfig.dist], { read: false }
    .pipe $.clean()

gulp.task 'rails-clean', ->
  gulp.src ['../public/*'], { dot: true, read: false }
    .pipe $.clean(force: true)

gulp.task 'build', ['html', 'images', 'fonts', 'extras']
gulp.task 'rails-build', ['rails-clean', 'rails-images', 'rails-html', 'rails-fonts', 'rails-extras']

gulp.task 'default', ['clean'], ->
  gulp.start 'build'

gulp.task 'connect', ->
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


gulp.task 'build-connect', ->
  connect = require 'connect'
  app     = connect()
    .use connect.static(appConfig.dist)
  require 'http'
    .createServer app
    .listen 9000
    .on 'listening', ->
      console.log 'Started connect web server on http://localhost:9000'

gulp.task 'serve', ['connect', 'templates', 'styles', 'coffee', 'scripts'], ->
  require('opn')('http://localhost:9000')

# inject bower components
gulp.task 'wiredep', ->
  wiredep = require('wiredep').stream

  gulp.src "#{appConfig.app}/styles/*.scss"
    .pipe wiredep
      directory: "#{appConfig.app}/bower_components"
      devDependencies: true
    .pipe gulp.dest("#{appConfig.app}/styles")

  gulp.src "#{appConfig.app}/*.html"
    .pipe wiredep
      directory: "#{appConfig.app}/bower_components"
      devDependencies: true
    .pipe gulp.dest(appConfig.app)

gulp.task 'wiredep-rails', ->
  wiredep = require('wiredep').stream
  replace = require('gulp-replace')

  gulp.src '../app/views/layouts/application.html.erb'
    .pipe wiredep
      directory: "#{appConfig.app}/bower_components"
    .pipe replace("../../../client/#{appConfig.app}/", '')
    .pipe gulp.dest('../app/views/layouts')

gulp.task 'livereload', ->
  liveReloadables = [
    "{#{appConfig.app},.tmp}/**/*.html"        # refreshes the browser
    "{#{appConfig.app},.tmp}/styles/**/*.css"  # reloads the CSS within the current page
    "{#{appConfig.app},.tmp}/scripts/**/*.js"  # refreshes the browser
    "#{appConfig.app}/images/**/*"             # (not sure)
  ]

  # watch for changes & notify the LiveReload server
  server = $.livereload()
  gulp.watch liveReloadables
    .on 'change', (file) -> server.changed file.path

watch = ->
  gulp.watch "#{appConfig.app}/styles/**/*.scss",    ['styles']
  watcher = gulp.watch "#{appConfig.app}/scripts/**/*.coffee", (event) ->
    if 'deleted' == event.type
      tmpPath = event.path
      .replace /\.coffee/, '.js'
      .replace new RegExp("/#{appConfig.app}/scripts"), '/.tmp/scripts'
      gulp.src(tmpPath, read: false).pipe($.clean())
    coffeeFiles = event.path
    gulp.start 'coffee'
  gulp.watch "#{appConfig.app}/scripts/**/*.js",     ['scripts']
  gulp.watch "#{appConfig.app}/images/**/*",         ['images']
  gulp.watch "#{appConfig.app}/partials/**/*.jade",  ['templates']

# gulp.watch 'these files', ['then do', 'these tasks', 'on each']
gulp.task 'watch', ['connect', 'serve', 'livereload'], ->
  gulp.watch 'bower.json',              ['wiredep']
  gulp.watch '.tmp/scripts/**/*.js',    (event) ->
    if ~['added', 'deleted'].indexOf event.type
      gulp.start 'wireup-only'
  watch()

gulp.task 'dev', ['templates', 'styles', 'coffee', 'scripts'], (cb)->
  gulp.watch 'bower.json',              ['wiredep-rails']
  gulp.watch '.tmp/scripts/**/*.js',    (event) ->
    if ~['added', 'deleted'].indexOf event.type
      gulp.start 'rails-wireup-only'
  watch()
  # TODO: do we want to start rails from here, and if so how?
  #require('child_process').exec 'cd .. && rails s', (err, stdout, stderr)->
    #console.log stdout
    #console.log stderr
    #cb(err)
  require('opn')('http://localhost:3000')

wireup = (dest)->
  destDir = dest.split('/').slice(0, -1).join('/')
  gulp.src(dest)
    .pipe($.inject(gulp.src('scripts/!(<%= dasherize(topLevelModuleName) %>|<%= dasherize(wireModuleName) %>)/**/*.js', {read: false, cwd: '.tmp'}), {name: 'inject-base', addRootSlash: false}))
    .pipe($.inject(gulp.src('scripts/<%= dasherize(wireModuleName) %>/**/*.js', {read: false, cwd: '.tmp'}), {name: 'inject-wire', addRootSlash: false}))
    .pipe($.inject(gulp.src('scripts/<%= dasherize(topLevelModuleName) %>/**/*.js', {read: false, cwd: '.tmp'}), {name: 'inject-app', addRootSlash: false}))
    .pipe(gulp.dest(destDir))

gulp.task 'wireup-only', -> wireup("#{appConfig.app}/index.html")
gulp.task 'wireup', ['coffee', 'wireup-only']
gulp.task 'rails-wireup-only', -> wireup('../app/views/layouts/application.html.erb')
gulp.task 'rails-wireup', ['coffee', 'rails-wireup-only']
