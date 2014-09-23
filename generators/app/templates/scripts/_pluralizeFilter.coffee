'use strict'

angular.module('<%= topLevelModuleName %>.<%= sharedModuleName %>')
  .filter 'pluralize', ->
    (singular, count, plural) ->
      plural ?= "#{singular}s"
      if count == 1 then singular else plural
