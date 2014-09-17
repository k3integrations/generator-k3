angular.module('<%= topLevelModuleName %>.<%= sharedModuleName %>').directive '<%= directiveNamespace %>StopClickPropagation', ->
  link: (scope, element, attrs)->
    element.on 'click', (e)->
      e.stopPropagation()
