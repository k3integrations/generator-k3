lib 'serve_static.rb', <<-CODE
# Serve static assets with fallthrough.
# This patch prevents the index.html from being served
require 'action_dispatch/middleware/static'

class MyFileHandler < ActionDispatch::FileHandler
  def ext
    @ext ||= begin
      ext = ::ActionController::Base.default_static_extension
      "{,\#{ext}}"
    end
  end
end

class ServeStatic < ActionDispatch::Static
  def initialize(app, path, cache_control=nil)
    @app = app
    @file_handler = MyFileHandler.new(path, cache_control)
  end
end
CODE

environment <<CONFIG, env: 'production'
  ####
  # Allows production env testing on dev machines by setting the
  # SERVE_ASSETS env variable
  #
  # Make sure to build the assets first
  #  $ (cd client && npm run rails-build)
  if ENV["SERVE_ASSETS"]
    puts "=> ### Serving Assets! ###"
    require 'serve_static'

    config.middleware.insert_after Rack::Sendfile, ServeStatic, './public'
  end
CONFIG

environment <<CONFIG, env: 'development'
  require 'serve_static'

  config.serve_static_assets = false # we don't serve from public directly, since the production build is usually there
  config.middleware.insert_after Rack::Lock, ServeStatic, './client/app'
  config.middleware.insert_after Rack::Lock, ServeStatic, './client/.tmp'
CONFIG

layout_path = 'app/views/layouts/application.html.erb'

run "rm #{layout_path}"

file layout_path, <<-CODE
<!doctype html>

<html class="no-js" lang="en" ng-app="{{NG_APP}}">

<head>
  <meta charset="utf-8" />
  <meta name="description" content="">
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="robots" content="noindex, nofollow">
  <base href="/">
  <%= csrf_meta_tags %>
  <title>#{camelized}</title>

  <%= stylesheet_link_tag "application" %>

  <% if Rails.env.production? || Rails.env.staging? %>
    <%= stylesheet_link_tag "vendor.css" %>
  <% else %>
    <!-- build:css assets/vendor.css -->
    <!-- bower:css -->
    <!-- endbower -->
    <!-- endbuild -->
  <% end %>

  <% if Rails.env.production? || Rails.env.staging? %>
    <%= stylesheet_link_tag "main.css" %>
  <% else %>
    <!-- build:css assets/main.css -->
    <link rel="stylesheet" href="styles/main.css">
    <!-- endbuild -->
  <% end %>

  <% if Rails.env.production? || Rails.env.staging? %>
    <%= javascript_include_tag 'vendor/modernizr.js' %>
  <% else %>
    <!-- build:js assets/vendor/modernizr.js -->
    <script src="bower_components/modernizr/modernizr.js"></script>
    <!-- endbuild -->
  <% end %>
</head>

<body>
  <div class="off-canvas-wrap">
    <div class="inner-wrap">
      <div id="page-content" class="page-content" alc-mark-when-top>
        <ng-include src="'partials/header.html'"></ng-include>
        <ng-include src="'partials/header-mobile.html'"></ng-include>

        <%= content_for?(:content) ? yield( :content ) : yield %>

        <ng-include src="'partials/footer.html'"></ng-include>
      </div>
    </div>
  </div>

  <% if Rails.env.production? || Rails.env.staging? %>
    <%= javascript_include_tag 'vendor.js' %>
  <% else %>
    <!-- build:js assets/vendor.js -->
    <!-- bower:js -->
    <!-- endbower -->
    <!-- endbuild -->
  <% end %>

  <% if Rails.env.production? || Rails.env.staging? %>
    <%= javascript_include_tag 'main.js' %>
  <% else %>
    <!-- build:js assets/main.js -->
    <!-- inject-base:js -->
    <!-- endinject -->
    <!-- inject-app:js -->
    <!-- endinject -->
    <!-- endbuild -->
  <% end %>
</body>

</html>
CODE

after_bundle do
  run "mkdir client"
  inside "client" do
    run "yo k3 #{camelized}"
  end
end
