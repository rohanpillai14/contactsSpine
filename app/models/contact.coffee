Spine = require('spine')
$ = Spine.$

class Contact extends Spine.Model
	# Configure name & attributes
	@configure 'Contact', 'serveid', 'name', 'email', 'phone'

	validate: ->
		"Name is required" unless @name
		"Email is needed in the format xyz@domain.com" unless /\b[a-z,0-9]+\@[a-z,0-9]{3,}\.[a-z,0-9]{2,3}\b/.test(@email)


	# Persist with Local Storage
	@extend Spine.Model.Local

	@extend Spine.Model.Ajax

	Spine.Model.host = "http://localhost:3000"

	#@url: "/contacts"

	@serverFields =
		'_id': 'serveid'
		'name': 'name'
		'email': 'email'
		'phone': 'phone'

	@filter: (query) ->
		return @all() unless query
		query = query.toLowerCase()
		@select (item) ->
			item.name?.toLowerCase().indexOf(query) isnt -1 or
				item.email?.toLowerCase().indexOf(query) isnt -1 or
					item.phone?.indexOf(query) isnt -1


	@getFromServer: (query) ->
		$.get(@url(query or= "")).done (data) =>
			data = [data] unless Spine.isArray(data)
			$.each data, (index, item) =>
				(new Contact(@changeFields(item))).save({ajax: false})

	@fromJSON: (objects) ->
    return unless objects
    if typeof objects is 'string'
      objects = JSON.parse(objects)
      value = @changeFields(objects)
    if Spine.isArray(objects)
      (new @(value) for value in objects)
    else
      new @(objects)


	@changeFields: (serverObject) ->
    console.log(serverObject)
    attrs = {}
    $.each serverObject, (key, val) =>
      attrs[@serverFields[key]] = val
    attrs


  @updateFromServer: (query) ->
    $.get(@url(query or= "")).done (data) =>
      data = [data] unless Spine.isArray(data)
      $.each data, (index, item) =>
        (new Contact(@changeFields(item))).save({ajax: false})

  
module.exports = Contact