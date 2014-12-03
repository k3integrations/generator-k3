angular.module('<%= wireModuleName %>').factory 'mockModels', ->
  # shortcuts / extensions
  A   = faker.address   # zipCode, city, cityPrefix, citySuffix, streetName, streetAddress, streetSuffix, secondaryAddress, county, country, state, stateAbbr, latitude, longitude
  C   = faker.company   # suffixes, companyName, companySuffix, catchPhrase, bs, catchPhraseAdjective, catchPhraseDescriptor, catchPhraseNoun, bsAdjective, bsBuzz, bsNoun
  D   = faker.date      # past, future, between, recent
  F   = faker.finance   # account, accountName, mask, amount, transactionType, currencyCode, currencyName, currencySymbol
  Ha  = faker.hacker    # abbreviation,  adjective, noun, verb, ingverb, phrase
  H   = faker.helpers   # randomNumber, randomize, slugify, replaceSymbolWithNumber, shuffle, mustache, createCard, contextualCard, userCard, createTransaction
  IMG = faker.image     # image, avatar, imageUrl, abstract, animals, business, cats, city, food, nightlife, fashion, people, nature, sports, technics, transport
  I   = faker.internet  # avatar, email, userName, domainName, domainSuffix, domainWord, ip, userAgent, color, password
  L   = faker.lorem     # words, sentence, sentences, paragraph, paragraphs
  N   = faker.name      # firstName, lastName, findName, prefix, suffix
  P   = faker.phone     # phoneNumber, phoneNumberFormat, phoneFormats
  R   = faker.random    # number, array_element, object_element

  sentences = (count) -> L.sentences(count).split("\n").join('. ') + '.'
  words     = (count) -> L.words(count).join ' '

  # Text/String utilities
  titleCaseText   = (text)  -> text.replace /\w\S*/g, capitalizeStr
  capitalizeText  = (text)  -> text.replace /\w[^\.\?\!]*/g, capitalizeStr
  capitalizeStr   = (str)   -> str.charAt(0).toUpperCase() + str.substr(1)


  # Mock Model Factory Base
  class MockModelFactory
    constructor: (@count, @models) ->
      @lastId = 0
      # lazy-load our collection so it can be easily used with other models
      Object.defineProperty @, 'collection',
        get: ->
          @_collection or= ( @generate() for i in [1..@count] )
          @_collection

    create: (attrs) ->
      newObj = _.merge {}, @generate(), attrs
      @collection.push newObj
      newObj

    update: (id, attrs) ->
      obj = @get id
      _.merge obj, attrs
      obj

    get: (id) ->
      _.find @collection, (obj) -> obj.id == id

    all: (count, offset = 0) ->
      start = offset
      end   = if count? then offset + count else @collection.length
      @collection.slice start, end

    generateId: -> ++@lastId

    generate: ->
      id: @generateId()


  # Example UserFactory using faker.Helpers.userCard() plus some others:
  #   id      : @generateId()
  #   name    : faker.Name.findName()
  #   username: faker.Internet.userName()
  #   email   : faker.Internet.email()
  #   address :
  #     street  : faker.Address.streetName(true)
  #     suite   : faker.Address.secondaryAddress()
  #     city    : faker.Address.city()
  #     zipcode : faker.Address.zipCode()
  #     geo     :
  #       lat     : faker.Address.latitude()
  #       lng     : faker.Address.longitude()
  #   phone   : faker.PhoneNumber.phoneNumber()
  #   website : faker.Internet.domainName()
  #   company :
  #     name        : faker.Company.companyName()
  #     catchPhrase : faker.Company.catchPhrase()
  #     bs          : faker.Company.bs()
  #   avatar  : faker.Internet.avatar()
  class UserFactory extends MockModelFactory
    generate: ->
      _.extend {},
        H.userCard(),
        id    : @generateId()
        avatar: I.avatar()


  # Our mock models; this is the returned object
  defaultCount  = 100
  mockModels    = {}
  _.merge mockModels,
    users       : new UserFactory defaultCount, mockModels

  mockModels
