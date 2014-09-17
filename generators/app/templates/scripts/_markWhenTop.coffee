angular.module('<%= topLevelModuleName %>.<%= sharedModuleName %>').directive '<%= directiveNamespace %>MarkWhenTop', ->
  link: (scope, element, attrs)->
    isAtTop = -> element.scrollTop() == 0

    setClass = ->
      if isAtTop()
        attrs.$addClass 'at-top'
        attrs.$removeClass 'not-at-top'
      else
        attrs.$addClass 'not-at-top'
        attrs.$removeClass 'at-top'

    setClass()
    element.on 'scroll', setClass
