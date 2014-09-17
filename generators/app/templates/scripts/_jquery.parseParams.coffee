( ($) ->
  re      = /([^&=]+)=?([^&]*)/g
  decode  = (str) -> decodeURIComponent str.replace /\+/g, ' '

  # recursive function to construct the result object
  createElement = (params = {}, key, value) ->
    key = "#{key}"

    if key.indexOf('.') != -1    # if the key is a property
      # extract the first part with the name of the object
      list = key.split '.'

      # the rest of the key
      new_key = key.split(/\.(.+)?/)[1]

      # create the object if it doesn't exist
      params[list[0]] = {} if !params[list[0]]

      # if the key is not empty, create it in the object
      if new_key != ''
        createElement params[list[0]], new_key, value
      else
        console.warn "parseParams :: empty property in key '#{key}'"

    else if key.indexOf('[') != -1   # if the key is an array
      # extract the array name
      list  = key.split '['
      key   = list[0]

      # extract the index of the array
      list  = list[1].split ']'
      index = list[0]

      # branch off if index is a word versus an integer

      params[key] = [] if !params[key] || !$.isArray params[key]

      # if index is empty, just push the value at the end of the array
      if index == ''
        params[key].push value
      else
        # add the value at the index (must be an integer)
        params[key][parseInt index] = value

    else  # just normal key
      params[key] = value


  $.parseParams = (query) ->
    # be sure the query is a string
    query = "#{if query? then query else window.location}"

    params  = {}
    e       = undefined

    unless query == ''
      # remove # from end of query
      if query.indexOf('#') != -1
        query = query.substr 0, query.indexOf('#')

      # remove ? at the begining of the query
      if query.indexOf('?') != -1
        query = query.substr query.indexOf('?') + 1, query.length

      unless query == ''
        # execute a createElement on every key and value
        while e = re.exec query
          key   = decode e[1]
          value = decode e[2]
          createElement params, key, value

    params

) jQuery
