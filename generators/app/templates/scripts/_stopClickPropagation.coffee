angular.module('<%= topLevelModuleName %>.<%= sharedModuleName %>').directive 'k3StopClickPropagation', ->
  link: (scope, element, attrs)->
    element.on 'click', (e)->
      e.stopPropagation()
