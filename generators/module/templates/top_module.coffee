appModules = [<% if (isWireframe) { %>
  'ui.router'
  'ngMockE2E'<% } %>
  #=== yeoman hook ===#
]

app = angular.module '<%= appName %>', appModules
<% if (isWireframe) { %>

app.run ($rootScope) ->
  # Allows us to flatten complex objects within forms into one flat object to
  # be used in $stateParams. All values will be normalized to strings.
  $rootScope.flatten = (objects...) -> _.merge {}, objects...

  $rootScope.JSONify = (object) -> JSON.stringify object


app.config ($stateProvider, $urlRouterProvider) ->
  'use strict'

  $urlRouterProvider.otherwise('/')
  $stateProvider
    .state('home',
      url: '/'
      templateUrl: 'partials/home.html'
    )
<% } %>
