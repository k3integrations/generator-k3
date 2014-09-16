module.exports = (config) ->
  config.set

   ## base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: ''


   ## frameworks to use
   ## available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['mocha', 'chai', 'sinon-chai']


   ## list of files / patterns to load in the browser
    files: [
      './<%= appPath %>/bower_components/jquery/dist/jquery.js'
      './<%= appPath %>/bower_components/angular/angular.js'<% if (angularModules.resourceModule) { %>,
      './<%= appPath %>/bower_components/angular-resource/angular-resource.js'<% } %><% if (angularModules.cookiesModule) { %>
      './<%= appPath %>/bower_components/angular-cookies/angular-cookies.js'<% } %><% if (angularModules.sanitizeModule) { %>
      './<%= appPath %>/bower_components/angular-sanitize/angular-sanitize.js'<% } %><% if (angularModules.animateModule) { %>
      './<%= appPath %>/bower_components/angular-animate/angular-animate.js'<% } %><% if (angularModules.touchModule) { %>
      './<%= appPath %>/bower_components/angular-touch/angular-touch.js'<% } %>
      './<%= appPath %>/bower_components/angular-mocks/angular-mocks.js'
      './<%= appPath %>/bower_components/angular-foundation/mm-foundation-tpls.js'
      './<%= appPath %>/bower_components/angular-ui-router/release/angular-ui-router.js'
      './<%= appPath %>/bower_components/angular-animate/angular-animate.js'
      './<%= appPath %>/bower_components/angular-ui-utils/ui-utils.js'
      './<%= appPath %>/bower_components/holderjs/holder.js'
      './<%= appPath %>/bower_components/moment/moment.js'
      './<%= appPath %>/scripts/**/*.coffee'
      './<%= testPath %>/**/*_spec.coffee'
    ]


   ## list of files to exclude
    exclude: [
    ]


   ## preprocess matching files before serving them to the browser
   ## available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      '**/*.coffee': ['coffee']
    }

    coffeePreprocessor:
      options:
        bare: false
        sourceMap: true

   ## test results reporter to use
   ## possible values: 'dots', 'progress'
   ## available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress']


   ## web server port
    port: 9876


   ## enable / disable colors in the output (reporters and logs)
    colors: true


   ## level of logging
   ## possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO


   ## enable / disable watching file and executing tests whenever any file changes
    autoWatch: true


   ## start these browsers
   ## available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome']


   ## Continuous Integration mode
   ## if true, Karma captures browsers, runs the tests and exits
    singleRun: false
