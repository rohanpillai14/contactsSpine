Spine = require('spine')
$ = Spine.$

class Contact extends Spine.Model
	# Configure name & attributes
	@configure 'Contact', 'serveid', 'name', 'email', 'phone'

	validate: ->
		"Name is required" unless @name
		"Email is needed in the format xyz@domain.com" unless /\b[a-z,0-9]+\@[a-z,0-9]{3,}\.[a-z,0-9]{2,3}\b/.test(@email)


	# Implement AJAX support
	@extend Spine.Model.Ajax

	# Persist with Local Storage
	@extend Spine.Model.Local


	Spine.Model.host = "http://localhost:3000"

	@url: "/contacts"


	###
	Object that contains the client-server bindings for attribute names
	Each attribute in this object is of the form 'clientAttrName': 'serverAttrName', where
	'clientAttrName' is the name of the attribute in the Model object for the corresponding
	'serverAttrName' attribute in the incoming JSON object from the server
	Specify only those attributes whose names differ on the client and server side (like id)
	###
	@serverFields =
		'_id': 'id'
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

	###
	Custom method to get all entries, or a specific entry from the server. The query parameter
	is a string representing the id of an entry on the server. The default value (blank string)
	gets all entries from the server
	###
	@getFromServer: (query = "") ->
		$.get(@url(query)).done (data) =>
			data = [data] unless Spine.isArray(data)
			$.each data, (index, item) =>
				(new Contact(@changeFields(item))).save({ajax: false})

	###
	Override of the default Spine fromJSON class method to allow for changes in the attribute names
	when converting from a server-returned JSON object to a set of model instances
	###
	@fromJSON: (objects) ->
	    return unless objects
	    if typeof objects is 'string'
	      objects = JSON.parse(objects)
	    if Spine.isArray(objects)
	      for value in objects
	        value = @changeFields(value)
	        new @(value)
	    else
	      objects = @changeFields(objects)
	      new @(objects)



	###
	Method that takes a single Javascript object that represents one of the entries in the JSON
	returned by the server. This method replaces the names of serverObject's attributes with the 
	corresponding names as implemented in the Model object. A hash of the mappings is contained 
	in the @serverFields object
	###
	@changeFields: (serverObject) ->
    	attrs = {}
    	$.each serverObject, (key, val) =>
      		attrs[@serverFields[key]] = val
    	attrs

  
module.exports = Contact