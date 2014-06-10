window.AddReservationView = class AddReservationView extends Backbone.View
  className: 'add-reservation'
  
  initialize: (options) ->
    @model = options.model

  events: ->
    'click button': 'save'
    'click #show-add-reservation': 'toggleAdd'
    'click #force-reservation': 'forceReservation'
    'click #cancel-reservation': 'cancelReservation'

  render: ->
    template = $('#add-reservation-template').html()
    $(@el).html _.template(template, {id: @model.get('id')})
    @

  save: ->
    reservation = new Reservation(@reservationData())
    reservation.save({}, {
      error: (model, response) =>
        if response.status is 406
          parsed_response = JSON.parse(response.responseText)
          @overCapacity(parsed_response.error)
        else
          @$('#errors').html "<p class=error>#{response}</p>"
      success: =>
        Backbone.eventHandler.trigger('reservation:added', {date: @model.get('date')})
        @model.fetch()
        $(@el).toggle()
    })

  forceReservation: ->
    reservation = new Reservation(@reservationData())
    reservation.force((response) =>
      if response is true
        Backbone.eventHandler.trigger('reservation:added', {date: @model.get('date')})
        @model.fetch()
        $(@el).toggle()
      else
        @$('#errors').html '<p class=error>Could not save!</p>'
    )

  cancelReservation: ->
    @render()

  toggleAdd: ->
    @$('#add-new-reservation').toggle()
    return false

  overCapacity: (message)->
    template = $('#add-reservation-error-template').html()
    @$('#errors').html _.template(template, {message: message})

  reservationData: ->
    scheduled_tour_id = @$("input[name='id']").val()
    contact_name = @$("input[name='contact_name']").val()
    phone = @$("input[name='phone']").val()
    email = @$("input[name='email']").val()
    people = @$("input[name='number_of_people']").val()
    place_of_stay = @$("input[name='place_of_stay']").val()
    comments = @$("textarea[name='comments']").val()
    {
      scheduled_tour_id: scheduled_tour_id,
      contact_name: contact_name, 
      phone: phone, 
      email: email, 
      number_of_people: people, 
      place_of_stay: place_of_stay,
      comments: comments
    }