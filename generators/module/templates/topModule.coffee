appModules = [<% if (isWireframe) { %>
  'ui.router'
  'ngMockE2E'<% } %>
  #=== yeoman hook ===#
]

app = angular.module '<%= moduleName %>', appModules
<% if (isWireframe) { %>

app.run ($rootScope) ->

app.config ($stateProvider, $urlRouterProvider) ->
  'use strict'

  $urlRouterProvider.otherwise('/')
  $stateProvider
    .state('home',
      url: '/'
      templateUrl: 'partials/home.html'
    )
    .state('login',
      params    : { 'login':{} }
      controller: ($stateParams, $state, $rootScope) ->
        login = $stateParams.login || {}
        email = login.email || ''
        $rootScope.wfUser =
          email : email
          name  : first: faker.Name.firstName(), last: faker.Name.lastName()
          admin : email.match(/^admin@/)?
        $state.go 'home'
    )
    .state('logout',
      url       : '/logout'
      controller: ($stateParams, $state, $rootScope) ->
        $rootScope.wfUser = undefined
        $state.go 'home'
    )
<% } %>
