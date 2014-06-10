window.OnTheFlyTourView = class OnTheFlyTourView extends Backbone.View
  el: '#tour-details'

  initialize: ->
    Backbone.eventHandler.on('onthefly:show', @showForm, @)
    Backbone.eventHandler.on('onthefly:hide', @hideForm, @)

  events: ->
    'click #save': 'scheduleTour'
    'click #cancel': 'cancel'
    'click #save-overriding-capacity': 'scheduleTourOverriding'
    'click #cancel-due-capacity': 'cancelOverriding'

  showForm: (payload) =>
    @date = payload.date
    @products = new ProductCollection()
    @products.bind('reset', @render)
    @products.fetch()

  hideForm: ->
    $(@el).fadeOut( ->
      $(@el).html ''
    )

  render: =>
    @buildProductOptions()
    $(@el).removeClass('cancelled-tour')
    $(@el).hide()
    $(@el).html _.template(@formTemplate(), {date: @date, products: @productOptions})
    $(@el).fadeIn()

  formTemplate: ->
    $('#on-the-fly-tour-template').html()

  buildProductOptions: =>
    @productOptions = ""
    @products.each((product) =>
      @productOptions = @productOptions + '<option value="' + product.get('id') + '">' + product.get('name') + "</option>\n"
    )

  scheduleTour: (event) ->
    event.preventDefault()
    @save(@tourData())

  save: (tourData) ->
    $('.new-on-the-fly-tour button').hide()
    tour = new OnTheFlyTour(tourData)
    tour.save({}, {
      error: (model, response) =>
        if response.status == 406
          parsed_response = JSON.parse(response.responseText)
          @notEnoughCapacity(parsed_response.error)
        else
          $('.new-on-the-fly-tour button').show()
          @$('#errors').html "<p class=error>#{response}</p>"
      success: (tour, response)=>
        tour.fetch()
        Backbone.eventHandler.trigger('onthefly:added', {selected_tour: tour.get('id')})
        Backbone.eventHandler.trigger('reservation:added', {date: tour.get('date')})
    })

  tourData: ->
    {
      product_id: @$("select[name='product_id']").val(),
      date: @$("input[name='date']").val(),
      reservation: {
        contact_name: @$("input[name='reservation[contact_name]']").val(),
        phone: @$("input[name='reservation[phone]']").val(),
        email: @$("input[name='reservation[email]']").val(),
        number_of_people: @$("input[name='reservation[number_of_people]']").val(),
        comments: @$("textarea[name='reservation[comments]']").val()
      }
    }

  cancel: (event)->
    event.preventDefault()
    Backbone.eventHandler.trigger('onthefly:hide')

  notEnoughCapacity: (message)->
    @$('#errors').hide()
    template = $('#on-the-fly-tour-errors-template').html()
    @$('#errors').html _.template(template, {message: message})
    @$('#errors').fadeIn()

  scheduleTourOverriding: (event) ->
    event.preventDefault()
    tour_data_overriding = @tourData()
    tour_data_overriding.override_capacity = true
    @save(tour_data_overriding)

  cancelOverriding: ->
    @$('#errors').fadeOut()
    @$('.new-on-the-fly-tour button').show()
