'use strict'

describe 'Decorator: <%= cameledName %>', ->

  # load the service's module
  beforeEach module '<%= scriptAppName %>'

  # instantiate service
  <%= cameledName %> = {}
  beforeEach inject (_<%= cameledName %>_) ->
    <%= cameledName %> = _<%= cameledName %>_

  it 'should do something', ->
    expect(!!<%= cameledName %>).toBe true
