appModules = [<% if (isWireframe) { %>
  'ui.router'
  'ngMockE2E'<% } %>
  #=== yeoman hook ===#
]

app = angular.module '<%= moduleName %>', appModules
<% if (isWireframe) { %>

app.run ($rootScope) ->
  # Do something based on the globalParam created below
  $rootScope.$on '$stateChangeSuccess', (e, to, toParams) ->
    if toParams.globalParam == 'true'
      $rootScope.globalParam = true
    return

app.config ($stateProvider, $urlRouterProvider) ->
  'use strict'

  # Add a globalParam to all states
  $stateProvider.decorator 'url', (state, urlMatcher) ->
    original = urlMatcher state
    if original?.sourceSearch?.match?
      unless original.sourceSearch.match /\?globalParam\b/
        return original.concat '?globalParam'
    original

  $urlRouterProvider.otherwise('/')
  $stateProvider
    .state('home',
      url: '/'
      templateUrl: 'partials/home.html'
    )
    .state('login',
      params    : { 'login':{} }
      controller: ($state, $rootScope, mockModels) ->
        login = $state.params.login || {}
        email = login.email || ''
        $rootScope.wfUser = _.merge {}, mockModels.users.generate(),
          email : email
          admin : email.match(/^admin@/)?
        $state.go 'home'
    )
    .state('logout',
      url       : '/logout'
      controller: ($state, $rootScope) ->
        $rootScope.wfUser = undefined
        $state.go 'home'
    )
<% } %>
