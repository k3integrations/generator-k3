'use strict'

###*
 # @ngdoc directive
 # @name <%= scriptAppName %>.directive:<%= namespacedCameledName %>
 # @description
 # # <%= namespacedCameledName %>
###
angular.module('<%= scriptAppName %>')
  .directive '<%= namespacedCameledName %>', ->
    template: """
      <div>{{myText}}, this is the <%= namespacedCameledName %> directive </div>
    """
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', ->
        console.log 'clicked'
        scope.$apply()
