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

coffee = (options = {watch: false})->
  source = "#{appConfig.app}/scripts/**/*.coffee"

  stream = gulp.src(source)

  if options.watch
    filterDeleted = $.filter (file)->
      file.event == 'deleted'

    watcher = $.watch source, name: "Coffee"

    stream = stream
      .pipe watcher
      .pipe filterDeleted
      .pipe $.rename (path)->
        path.originalDirname = path.dirname
        path.dirname = '../../.tmp/scripts/' + path.dirname
        path.extname = ".js"
        return
      .pipe $.rimraf()
      .pipe filterDeleted.restore()

  stream.pipe $.sourcemaps.init()
    .pipe $.coffee()
    .on 'error', (err) ->
      console.log err.stack
      @emit 'end'
    .pipe $.sourcemaps.write('./maps')
    .pipe gulp.dest('.tmp/scripts/')

gulp.task 'coffee', -> coffee(watch: false)

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


gulp.task 'html', gulp.series gulp.parallel('templates', 'styles', 'coffee', 'scripts'), -> html(appConfig.dist)
gulp.task 'rails-html', gulp.series gulp.parallel('templates', 'styles', 'coffee', 'scripts'), ->
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
    .pipe $.rimraf()

gulp.task 'rails-clean', ->
  gulp.src ['../public/*'], { dot: true, read: false }
    .pipe $.clean(force: true)

gulp.task 'build', gulp.parallel('html', 'images', 'fonts', 'extras')
gulp.task 'rails-build', gulp.series('rails-clean', gulp.parallel('rails-images', 'rails-html', 'rails-fonts', 'rails-extras'))

gulp.task 'default', gulp.series('clean', 'build')

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
  gulp.src "#{appConfig.app}/styles/*.scss"
    .pipe wireStream
      directory: "#{appConfig.app}/bower_components"
      devDependencies: true
    .pipe gulp.dest("#{appConfig.app}/styles")

# inject all dependencies (bower, app)
wireup = (dest, options={rails:false})->
  wireStream = require('wiredep').stream
  replace = require('gulp-replace')

  destDir = dest.split('/').slice(0, -1).join('/')

  stream = gulp.src(dest)
    .pipe($.inject(gulp.src('scripts/!(<%= dasherize(topLevelModuleName) %>|<%= dasherize(wireModuleName) %>)/**/*.js', {read: false, cwd: '.tmp'}), {name: 'inject-base', addRootSlash: false}))
    .pipe($.inject(gulp.src('scripts/<%= dasherize(wireModuleName) %>/**/*.js', {read: false, cwd: '.tmp'}), {name: 'inject-wire', addRootSlash: false}))
    .pipe($.inject(gulp.src('scripts/<%= dasherize(topLevelModuleName) %>/**/*.js', {read: false, cwd: '.tmp'}), {name: 'inject-app', addRootSlash: false}))

    stream = if options.rails
      stream.pipe wireStream
        directory: "#{appConfig.app}/bower_components"
      .pipe replace("../../../client/#{appConfig.app}/", '')
    else
      stream.pipe wireStream
        directory: "#{appConfig.app}/bower_components"
        devDependencies: true

    stream.pipe(gulp.dest(destDir))

wiredep      = -> wireup "#{appConfig.app}/*.html"
wiredepRails = -> wireup '../app/views/layouts/application.html.erb', rails: true

gulp.task 'wireupJavascriptRails', wiredep
gulp.task 'wireupJavascript', wiredep
gulp.task 'wireupSass', wireupSass

# Important: we must start wiredep only after coffee has been run, therefore,
# we cannot just _depend_ on this like we do with coffee, otherwise coffee will
# run parallel to wiredep
gulp.task 'wiredep', gulp.parallel('wireupJavascript', 'wireupSass')
gulp.task 'rails-wiredep', gulp.parallel('wireupJavascriptRails', 'wireupSass')

gulp.task 'serve', gulp.series gulp.parallel('connect', 'templates', 'styles', 'coffee', 'scripts'), 'wiredep', (cb)->
  require('opn')('http://localhost:9000')
  cb()


gulp.task 'livereload', (cb)->
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
  cb()

watch = ->
  gulp.watch "#{appConfig.app}/styles/**/*.scss",    ['styles']
  gulp.watch "#{appConfig.app}/scripts/**/*.js",     ['scripts']
  gulp.watch "#{appConfig.app}/images/**/*",         ['images']
  gulp.watch "#{appConfig.app}/partials/**/*.jade",  ['templates']
  # TODO: since the tasks running this usually depend on coffee already, I
  # think we end up running coffee twice. We should figure out a
  # way to prevent that
  coffee(watch: true)

# gulp.watch 'these files', ['then do', 'these tasks', 'on each']
gulp.task 'watch', gulp.series 'clean', gulp.parallel('serve', 'livereload'), (cb)->
  gulp.watch 'bower.json', ['wiredep']
  gulp.watch('.tmp/scripts/**').on 'change', (event)->
    wiredep() if ~['added', 'deleted'].indexOf(event.type)
  watch()
  cb()

gulp.task 'dev', gulp.series 'clean', gulp.parallel('templates', 'styles', 'scripts', wiredep), (cb)->
  gulp.watch 'bower.json', ['rails-wiredep']
  gulp.watch('.tmp/scripts/**').on 'change', (event)->
  gulp.watch('.tmp/scripts/**').on 'change', (event)->
    wiredepRails() if ~['added', 'deleted'].indexOf(event.type)

  watch()
  # TODO: do we want to start rails from here, and if so how?
  #require('child_process').exec 'cd .. && rails s', (err, stdout, stderr)->
    #console.log stdout
    #console.log stderr
    #cb(err)
  require('opn')('http://localhost:3000')
  cb()
