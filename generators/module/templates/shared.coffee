sharedModules = [
  'mm.foundation'
  'ui.utils'<% if (animateModule) { %>
  'ngAnimate'<% } %><% if (cookiesModule) { %>
  'ngCookies'<% } %><% if (resourceModule) { %>
  'ngResource'<% } %><% if (sanitizeModule) { %>
  'ngSanitize'<% } %><% if (touchModule) { %>
  'ngTouch'<% } %>
]

angular.module('<%= topLevelModuleName %>.<%= moduleName %>', sharedModules)

  .config ($httpProvider) ->

    $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')

    # TODO: Will made something for something. Ask Nick. Or Will. Or Hugh.
