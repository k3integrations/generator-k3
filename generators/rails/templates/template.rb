
# Add our custom static file serving Middleware for serving assets from client
lib 'serve_static.rb', <<-RUBY
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
RUBY

# Insert our custom middleware in production
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

# Insert our custom middleware in development
environment <<CONFIG, env: 'development'
  require 'serve_static'

  config.serve_static_assets = false # we don't serve from public directly, since the production build is usually there
  config.middleware.insert_after Rack::Lock, ServeStatic, './client/app'
  config.middleware.insert_after Rack::Lock, ServeStatic, './client/.tmp'
CONFIG


# Update the default application layout
layout_path = 'app/views/layouts/application.html.erb'

# Remove the existing layout so we don't have a prompt requiring us to allow the overwrite
run "rm #{layout_path}"

# Write out an entirely new application.html.erb layout with a hook for the yeoman generator to inject the AngularJS app name.
file layout_path, <<-HTML
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
HTML


# Add the jade2haml script so we can easily convert wireframe jade files to Rails app haml files
file "script/jade2haml", <<-RUBY
#!/usr/bin/env ruby

unless ARGV[0] && ARGV[1]
  STDOUT.puts <<-EOF
jade2haml is essentially a shortcut for doing `jade < INPUT | html2haml --stdin --html-attributes OUTPUT

Usage:
  jade2haml INPUT OUTPUT
EOF
  exit 0
end

# TODO: maybe just use the system jade command-line tool by default and add an
#   option for setting --jade-path or something
# IF YOU FIX THIS, please add it back into the generator-k3 template.rb file
jade_bin = File.expand_path('./client/node_modules/jade/bin/jade.js')

unless File.exist?(jade_bin)
  STDOUT.puts 'Cannot find jade CLI.', "  path: \#{jade_bin}"
  exit 1
end

input_file  = File.expand_path ARGV[0]
output_file = File.expand_path ARGV[1]

unless File.exist?(input_file)
  STDOUT.puts "Could not find file: \#{input_file}"
  exit 0
end

# TODO: parse options and detect a --debug or --verbose option to use this output
# IF YOU FIX THIS, please add it back into the generator-k3 template.rb file
# STDOUT.puts <<-EOF
# jade path:    \#{jade_bin}
# input file:   \#{input_file}
# output file:  \#{output_file}
# EOF

# STDOUT.puts "jade < \#{ARGV[0]} | html2haml --stdin --html-attributes \#{ARGV[1]}"

`"\#{jade_bin}" < "\#{input_file}" | html2haml -s --html-attributes "\#{output_file}"`

STDOUT.puts 'success'
RUBY


# create our client directory and run the base yo k3 generator
after_bundle do
  run "mkdir client"
  inside "client" do
    run "yo k3 #{camelized}"
  end
end
