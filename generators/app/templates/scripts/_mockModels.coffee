angular.module('<%= wireModuleName %>').factory 'mockModels', ->
  # shortcuts / extensions
  A   = faker.Address     # zipCode, zipCodeFormat, city, streetName, streetAddress, secondaryAddress, brState, ukCounty, ukCountry, usSate, latitude, longitude
  C   = faker.Company     # companyName, companySuffix, catchPhrase, bs
  D   = faker.Date        # past, future, between, recent
  H   = faker.Helpers     # randomNumber, randomize, slugify, replaceSymbolWithNumber, shuffle, createCard, userCard
  I   = faker.Internet    # email, userName, domainName, domainWord, ip, color
  IMG = faker.Image       # avatar, imageUrl, abstractImage, animals, business, cats, city, food, nightLife, fashion, people, nature, sports, technics, transport
  L   = faker.Lorem       # words, sentence, sentences, paragraph, paragraphs
  N   = faker.Name        # firstName, firstNameFemale, firstNamemale, lastName, findName
  P   = faker.PhoneNumber # phoneNumber, phoneNumberFormat
  T   = faker.Tree        # clone, createTree


  # Text Helpers
  sentences = (count) -> L.sentences(count).split("\n").join('. ') + '.'
  words     = (count) -> L.words(count).join ' '

  titleCaseText   = (text)  -> text.replace /\w\S*/g, capitalizeStr
  capitalizeText  = (text)  -> text.replace /\w[^\.\?\!]*/g, capitalizeStr
  capitalizeStr   = (str)   -> str.charAt(0).toUpperCase() + str.substr(1)


  # Mock Model Factory Base
  class MockModelFactory
    constructor: (@count) ->
      @lastId = 0
      @generateCollection()

    generateCollection: ->
      @collection = ( @generate() for i in [1..@count] )

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
  #   avatar  : faker.Image.avatar()
  class UserFactory extends MockModelFactory
    generate: ->
      _.extend {},
        H.userCard(),
        id    : @generateId()
        avatar: IMG.avatar()


  # Our mock models; this is the returned object
  defaultCount  = 100
  mockModels    =
    users       : new UserFactory(defaultCount)

  mockModels
