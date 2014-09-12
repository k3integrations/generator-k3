angular.module('<%= topLevelModuleName %>.<%= moduleName %>', [
  '<%= topLevelModuleName %>.<%= sharedModuleName %>',
]).config ($routeProvider) ->
    $routeProvider
      .otherwise
        templateUrl: '404_error'
