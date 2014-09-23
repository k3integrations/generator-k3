'use strict'

angular.module('<%= topLevelModuleName %>.<%= sharedModuleName %>')
  .filter 'truncate', ->
    (text, length = 30, omission = '…') ->
      return text if text.length <= length
      text.slice(0, length - omission.length) + omission
