Spine   = require('spine')
Contact = require('models/contact')
List = require('spine/lib/list')
$       = Spine.$

class Sidebar extends Spine.Controller
  className: 'sidebar'

  elements:
    '.items': 'items'
    'input': 'search'

  events:
    'keyup input': 'filter'
    'click .item': 'clicked'
    'click footer button': 'create'

  constructor: ->
    super
    # Render initial view
    @html require('views/sidebar')()

    # Setup a Spine List
    @list = new Spine.List
      el: @items, 
      template: require('views/item'), 
      selectFirst: true

    @list.bind 'change', @change

    # Fetch the list of contacts from the server
    Contact.fetch({}, {clear:true})

    @active (params) -> 
      @list.change(Contact.find(params.id))
      $(".items .item").removeClass("selected")
      $("#" + params.id).addClass("selected")

    Contact.bind('refresh change', @render)
    Contact.bind("create", @createGateway)

  filter: ->
    @query = @search.val()
    @render()

  render: =>
    contacts = Contact.filter(@query)
    @list.render(contacts)

  flip: ->
    if $(window).width() <= 520
      $(".main").css({"z-index": 20})

  clicked: (e) ->
    $(e.target).addClass("selected")
    @flip()

  change: (item) =>
    @navigate '/contacts', item.id

  create: ->
    @flip()
    @navigate('/contacts/new')

  createGateway: =>
    Contact.bind("ajaxSuccess", @afterCreate)
    
  ###
  Callback function that creates and saves copy of the newly created contact locally, and deletes 
  the old version with the local id
  ###
  afterCreate: (status, xhr) =>
    if xhr.id
      if current = Contact.find(xhr.id)
        localID = current.id
        current.updateAttribute("id", current["_id"], {ajax: false})
        Contact.destroy(localID, { ajax: false})
        Contact.unbind("ajaxSuccess")
        @navigate('/contacts', current.id)


module.exports = Sidebar