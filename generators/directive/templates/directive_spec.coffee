'use strict'

describe 'Directive: <%= namespacedCameledName %>', ->

  # load the directive's module
  beforeEach module '<%= scriptAppName %>'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<<%= _.dasherize(namespacedCameledName) %>></<%= _.dasherize(namespacedCameledName) %>>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the <%= namespacedCameledName %> directive'
