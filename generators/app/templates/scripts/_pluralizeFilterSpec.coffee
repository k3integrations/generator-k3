'use strict'

describe 'Filter: pluralize', ->

  # load the filter's module
  beforeEach module '<%= topLevelModuleName %>.<%= sharedModuleName %>'

  # initialize a new instance of the filter before each test
  pluralize = {}
  beforeEach inject ($filter) ->
    pluralize = $filter 'pluralize'

  it 'just gives back the given word when the count is 1', ->
    expect(pluralize 'file', 1).to.eq 'file'

  it 'simply appends an "s" when the count is not 1', ->
    expect(pluralize 'file', 0).to.eq 'files'

  it 'accepts a pluralized form and uses it when count is not 1', ->
    expect(pluralize 'one', 3, 'some').to.eq 'some'
