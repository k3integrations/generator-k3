'use strict'

describe 'Decorator: <%= cameledName %>', ->

  # load the service's module
  beforeEach module '<%= scriptAppName %>'

  # instantiate service
  <%= cameledName %> = {}
  beforeEach inject (_<%= cameledName %>_) ->
    <%= cameledName %> = _<%= cameledName %>_

  it 'does something', ->
    expect(!!<%= cameledName %>).to.be.true
