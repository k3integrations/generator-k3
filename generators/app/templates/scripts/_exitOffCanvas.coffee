angular.module('<%= topLevelModuleName %>.<%= sharedModuleName %>').directive 'k3ExitOffCanvas', ->
  require   : '^offCanvasWrap'
  restrict  : 'AC'
  link      : ($scope, element, attrs, offCanvasWrap) ->
    element.on 'click', -> offCanvasWrap.hide()
