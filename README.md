# K3 Wireframing Generators for Yeoman

## Prerequisites

- rails 4.2: `gem install rails`
- node and npm: `brew install node`
- karma: `npm install -g karma-cli`
- gulp: `npm install -g gulp` (latest)
- bower: `npm install -g bower`
- yeoman: `npm install -g yo`


## Installation

To install this set of custom Yeoman generators, do the following:

- clone the repository to your local system
- navigate to the project’s root directory
- run `npm link`


## Quick Start Guide

To get you up and running in a hurry!

    $ yo k3:rails [args to `rails new`]

… follow the on-screen instructions & wait for dependencies to download and install …

    $ cd [AppName]/client
    $ gulp watch
    $ yo k3:directive <name> # etc.


## Wireframe-first Approach to Development

### Wireframing Conventions

- Scope variable prefixes (`wfMyVar`)
  - makes it easy to spot wireframe only variables on integration
- Rails controllers replaced with controller in `ui-routes`
  - no dedicated controller file created
    - because we want as little extra markup as possible that won’t end up in the Rails app (an extra `ng-controller` is just another thing to have to remove)
- Rails’ `yield` replaced with `ui-view`
- Rails’ `render` replaced with `ng-include`
- Don’t use a lot of JavaScript in a view unless the JavaScript is going to be in the final Rails app as well
  - if it’s necessary, then make sure it’s isolated in the `Wire` namespace
- When making requests, use `$httpBackend` mock service, this makes it easy to hook up to Rails later
- Wireframe project is included in main project as a git submodule
- If you make a service that only works in one of the two environments, at least make a dummy to fill its spot for the other environment
- Replace Rails controllers and routes with an entry in ui-router providing the needed (prefixed) scope variables and any other Wireframe-only functionality
- **Rule of thumb:**
  - Any script file not in the `Wire` module should be designed in such a way as to work with Rails eventually _without_ modification. Usually the only place this is not possible is in the views, but those should only have attributes of equivalent functionality to the a Rails counterpart (e.g. `ng-repeat` becomes a `.each do` loop).
  - A view that you know is going to be served by Rails later should not have dependencies on any routing or controllers, unless the controller is expected to be in the Rails app as well. Directives are the preferred interface between Rails and JavaScript.


## Generator API

### k3:app [appName]

    $ yo k3 MyApp

Generates a basic app setup. This is the default task that will run if you don’t give a specific generator to the `k3` namespace. If no `appName` is given, it will try to guess it from the parent directory’s name.

### k3:constant <constantName>

    $ yo k3:constant TheTruth

Creates an AngularJS constant service and hooks it into the app. Also creates a spec file for testing.

### k3:controller <controllerName>

    $ yo k3:controller Things

Creates an AngularJS controller (post-fixes the name with “Ctrl”, so, “ThingsCtrl” in this example). Also creates a spec file for testing.

### k3:decorator <decoratedServiceName>

    $ yo k3:decorator Things

Creates a decorator for the specified service. Also creates a spec file for testing.

### k3:directive <directiveName>

    $ yo k3:directive SpecialButton

Creates an AngularJS directive file and hooks it into the app. Also creates a spec file for testing. The name given will be prefixed with the directive namespace that was created when `k3:app` was initially run. This namespace can be found in the .yo-rc.json file.

### k3:factory <factoryName>

    $ yo k3:factory Widget

Creates an AngularJS factory and hooks it into the app. Also creates a spec file for testing.

### k3:filter <filterName>

    $ yo k3:filter truncate

Creates an AngularJS filter file and hooks it into the app. Also creates a spec file for testing. The convention is to use camel-cased names with the first letter lowercased.

### k3:module <moduleName> [--shared|--topLevel|--isWireframe|--(animate|cookies|resource|sanitize|touch)Module]

    $ yo k3:module Home

Creates a directory for the module and an AngularJS module file called main.coffee inside of it. When given the `--shared` option, it will create a special module that will be shared with all other modules. When given the `--topLevel` option, it creates a module that is expected to be used at the top-level of an app (like in the `<html>` tag of the main index.html file). When `k3:app` is run, it prompts for the names of your top-level module, your shared module and the first module of your app. It composes with this generator to actually generate those modules and uses the available options outlined above to make that happen.

### k3:provider <providerName>

    $ yo k3:provider Widget

Creates an AngularJS provider and hooks it into the app. Also creates a spec file for testing.

### k3:route _(coming soon)_

### k3:service <serviceName>

    $ yo k3:service Widget

Creates an AngularJS service and hooks it into the app. Also creates a spec file for testing.

### k3:value <variableName>

    $ yo k3:value answerToEverything

Creates an AngularJS value service and hooks it into the app. Also creates a spec file for testing.

### k3:view _(coming soon)_


## TODO

- add jade2haml script
- fix NG_APP injector
- update copyright at bottom of main layout
