faker?.Name?.findName = ->
  _name = faker.Name
  r     = faker.random.number 8
  switch r
    when 0
      "#{faker.random.name_prefix()} #{_name.firstName()} #{_name.lastName()}"
    when 1
      "#{_name.firstName()} #{_name.lastName()} #{faker.random.name_suffix()}"
    else "#{_name.firstName()} #{_name.lastName()}"
