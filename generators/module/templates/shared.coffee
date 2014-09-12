angular.module('<%= topLevelModuleName %>.<%= moduleName %>', ['ngRoute', '<%= topLevelModuleName %>.Templates'])

  .config ($locationProvider, $httpProvider) ->

    # Setup configuration for AngularJS routes and partials.
    $locationProvider.html5Mode true
    $locationProvider.hashPrefix '!'

    $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');


  .run ($templateCache)->
    # Define global 404 page fallback
    $templateCache.put '404_error', '<h1>404: Missing that page.</h1>'
