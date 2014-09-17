angular.module('<%= wireModuleName %>').run ($httpBackend, $state, $rootScope, mockModels) ->

  # allow all partial loading to pass through
  $httpBackend.whenGET(/^partials\//).passThrough()


  # capture requests for JSON data
  $httpBackend.whenGET(/^users/).respond (method, url, data) ->
    users = mockModels.users.all params(url).count || 100
    [200, users, {}]


  # capture form requests
  $httpBackend.whenPOST(/^users/).respond (method, url, data) ->
    $rootScope.wfUser = JSON.parse data
    $state.go 'dashboard'
    [302, '', {}]


  params = (url) -> $.parseParams url
