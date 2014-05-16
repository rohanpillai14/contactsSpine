Spine 	= require('spine')
Contact = require('models/contact')
$		= Spine.$
    
class Show extends Spine.Controller
	# Set the HTML class
	className: 'show col-xs-12 col-sm-12'

	events:
		'click .edit' : 'edit'
		'click .delete': 'delete'
		'click .back' : 'flip'

	constructor: ->
		super

		# Bind the change() callback to the *active* event
		@active @change

	render: ->
		# Render a template, replacing the controller's HTML
		$(".edit").hide()
		$(".show").show()
		@html require('views/show')(@item)

	change: (params) =>
		@item = Contact.find(params.id)
		@render()

	edit: ->
		# Navigate to the 'edit' view whenever the edit link is clicked
		@navigate('/contacts', @item.id, 'edit')

	delete: ->
		if confirm('Are you sure?')
			@item.destroy()
			@flip()
		@navigate('/contacts', Contact.first().id)

	flip: ->
		if $(window).width() <= 520
			$(".main").css({"z-index": -1})

class Edit extends Spine.Controller
	className: 'edit col-xs-12 col-sm-12'

	events:
		'submit form': 'submit'
		'click .save': 'submit'
		'click .cancel': 'cancel'

	elements:
		'form': 'form'

	constructor: ->
		super
		@active @change

	render: () ->
		$(".show").hide()
		$(".edit").show()
		@html require('views/form')(@item)
		$("#nameField").focus()

	change: (params) =>
		if params.page is "new" then @item = null
		else 
			@item = Contact.find(params.id)
		@render()

	submit: (e) ->
		e.preventDefault()
		if @item
			@item.fromForm(@form)
			unless @item.save()
				msg = @item.validate()
				return alert(msg)
		else 
			@item = Contact.fromForm(@form)
			unless @item.create()
				msg = @item.validate()
				return alert(msg)
		@navigate('/contacts', @item.id)

	cancel: ->
		if $(window).width() <= 520
			$(".main").css({"z-index": -1})
		@navigate('/contacts', Contact.first().id)
	

class Main extends Spine.Stack
	className: 'main stack'

	controllers:
		show: Show
		edit: Edit

module.exports = Main