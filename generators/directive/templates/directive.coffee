'use strict'

###*
 # @ngdoc directive
 # @name <%= scriptAppName %>.directive:<%= namespacedCameledName %>
 # @description
 # # <%= namespacedCameledName %>
###
angular.module('<%= scriptAppName %>')
  .directive('<%= namespacedCameledName %>', ->
    template: '<div></div>'
    restrict: 'E'
    link: (scope, element, attrs) ->
      element.text 'this is the <%= namespacedCameledName %> directive'
  )
