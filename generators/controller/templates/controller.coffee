'use strict'

###*
 # @ngdoc function
 # @name <%= scriptAppName %>.controller:<%= cameledName %>Ctrl
 # @description
 # # <%= cameledName %>Ctrl
 # Controller of the <%= scriptAppName %>
###
angular.module('<%= scriptAppName %>')
  .controller '<%= name %>Ctrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
