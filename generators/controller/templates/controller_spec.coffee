'use strict'

describe 'Controller: <%= cameledName %>Ctrl', ->

  # load the controller's module
  beforeEach module '<%= scriptAppName %>'

  <%= cameledName %>Ctrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    <%= cameledName %>Ctrl = $controller '<%= cameledName %>Ctrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).to.eq 3
