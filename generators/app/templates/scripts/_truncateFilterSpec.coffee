'use strict'

describe 'Filter: truncate', ->

  # load the filter's module
  beforeEach module '<%= topLevelModuleName %>.<%= sharedModuleName %>'

  # initialize a new instance of the filter before each test
  beforeEach inject ($filter) ->
    @text = 'The quick brown fox jumps over the lazy dog. ' +
            'Who packed five dozen old quart jugs in my box?'
    @truncate = $filter 'truncate'

  it 'returns the given text truncated to 30 characters by default', ->
    expect(@truncate @text).to.eq @text.slice(0, 29) + '…'

  it 'returns the full given text when it is less than the desired length', ->
    expect(@truncate @text, 300).to.eq @text

  it 'uses a custom truncation length when provided', ->
    expect(@truncate @text, 10).to.eq 'The quick…'

  it 'uses a custom omission placeholder when provided', ->
    expect(@truncate @text, 30, '>>>').to.eq @text.slice(0, 27) + '>>>'
