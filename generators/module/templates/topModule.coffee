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
<% } %>
