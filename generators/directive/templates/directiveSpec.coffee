'use strict'

describe 'Directive: <%= namespacedCameledName %>', ->

  # load the directive's module
  beforeEach module '<%= scriptAppName %>'

  beforeEach inject ($rootScope, $compile)->
    @scope = $rootScope.$new()
    @el    = angular.element """
      <div <%= dasherize(namespacedCameledName) %>></div>
    """
    $compile(@el)(@scope)
    @scope.myText = "Hello World"
    @scope.$apply()

  it 'injects the expected text',  ->
    expect(@el.text()).to.eq 'Hello World, this is the <%= namespacedCameledName %> directive'
