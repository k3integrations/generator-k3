sharedModules = [
  'mm.foundation'
  'ui.utils'<% if (options.animateModule) { %>
  'ngAnimate'<% } %><% if (options.cookiesModule) { %>
  'ngCookies'<% } %><% if (options.resourceModule) { %>
  'ngResource'<% } %><% if (options.sanitizeModule) { %>
  'ngSanitize'<% } %><% if (options.touchModule) { %>
  'ngTouch'<% } %>
]

angular.module('<%= topLevelModuleName %>.<%= moduleName %>', sharedModules)

  .config ($httpProvider) ->

    $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')

    # TODO: Will made something for something. Ask Nick. Or Will. Or Hugh.
