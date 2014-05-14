Spine 	= require('spine')
Contact = require('models/contact')
$		= Spine.$
    
class Show extends Spine.Controller
	# Set the HTML class
	className: 'show'

	events:
		'click .edit' : 'edit'
		'click .delete': 'delete'

	constructor: ->
		super

		# Bind the change() callback to the *active* event
		@active @change

	render: ->
		# Render a template, replacing the controller's HTML
		@html require('views/show')(@item)

	change: (params) =>
		@item = Contact.find(params.id)
		@render()

	edit: ->
		# Navigate to the 'edit' view whenever the edit link is clicked
		@navigate('/contacts', @item.id, 'edit')

	delete: ->
		@item.destroy() if confirm('Are you sure?')
		@navigate('/contacts', Contact.first().id)

class Edit extends Spine.Controller
	className: 'edit'

	events:
		'submit form': 'submit'
		'click .save': 'submit'

	elements:
		'form': 'form'

	constructor: ->
		super
		@active @change

	render: () ->
		@html require('views/form')(@item)
		$("#nameField").focus()

	change: (params) =>
		if params.page is "new" then @item = null
		else 
			@item = Contact.find(params.id)
		@render()

	submit: (e) ->
		e.preventDefault()
		if @item then @item.fromForm(@form)
		else @item = Contact.fromForm(@form)
		unless @item.save()
			msg = @item.validate()
			return alert(msg)
		@navigate('/contacts', @item.id)
	

class Main extends Spine.Stack
	className: 'main stack'

	controllers:
		show: Show
		edit: Edit

module.exports = Main