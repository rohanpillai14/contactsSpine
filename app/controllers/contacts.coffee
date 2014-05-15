Spine = require('spine')
Contact = require('models/contact')
Manager = require('spine/lib/manager')
$ = Spine.$

Main = require('controllers/contacts_main')
Sidebar = require('controllers/contacts_sidebar')

class Contacts extends Spine.Controller
	className: 'contacts'

	constructor: ->
		super

		@sidebar = new Sidebar
		@main = new Main

		@routes
			'/contacts/:id/edit': (params) ->
				params.page = "edit"
				@sidebar.active(params)
				@main.edit.active(params)
			'/contacts/new': (params) ->
				params.page = "new"
				@sidebar.active(params)
				@main.edit.active(params)
			'/contacts/:id': (params) ->
				params.page = "show"
				@sidebar.active(params)
				@main.show.active(params)

		divide = $('<div />').addClass('vdivide')

		@append @sidebar, divide, @main

		# Contact.fetch()

    
module.exports = Contacts