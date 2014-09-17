'use strict'

angular.module('<%= topLevelModuleName %>.<%= sharedModuleName %>').directive 'wfHolder', ->
  link: (scope, element, attrs) ->
    attrs.$set 'data-src', attrs.wfHolder
    Holder.run
      images: element.get(0),
      nocss : true
