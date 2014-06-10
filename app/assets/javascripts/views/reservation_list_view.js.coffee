window.ReservationListView = class ReservationListView extends Backbone.View
  className: 'reservations'
  tagName: 'ul'

  initialize: (options) ->
    @collection = options.collection
    
  render: ->
    i = 0
    sorted = @collection.sort (a, b) ->
      return (a.id > b.id) ? 1 : -1
    _.each(sorted, (reservation) =>
      rowColor = 'odd-row'
      if i % 2 is 0
        rowColor = 'even-row'
      
      $(@el).append new ReservationView({
        tour_cancelled: this.options.tour_cancelled,
        selected: (reservation.id == this.options.selected_rez_id),
        scheduled_tour_id: this.options.scheduled_tour_id, 
        model: reservation, 
        rowColor: rowColor}
      ).render().el
      i++
    )
    @

  reservationCanceled: ->
    @collection.fetch()

window.ReservationView = class ReservationView extends Backbone.View
  tagName: 'li'
  
  initialize: (options) ->
    #@model = options.model
    @rowColor = options.rowColor
    @startingReservationId = 2000

  events: ->
    'click .reservation-header': 'toggleDetails'
    'click a.cancel-reservation': 'toggleConfirmCancelation'
    'click a.uncancel-reservation': 'confirmUncancel'
    'click a.edit-reservation': 'toggleEditForm'
    'click .confirm-reservation-cancelation': 'cancelReservation'
    'click .do-not-cancel-reservation': 'toggleConfirmCancelation'
    'click .save-edit': 'save'
    'click .cancel-edit': 'toggleEditForm'
    
  render: ->
    template = $('#reservation-item-template').html()
    $(@el).addClass(@rowColor)
    if !@model.place_of_stay
      @model.place_of_stay = ""
    $(@el).html _.template(template, {
      model: @model, 
      id: @model.id + @startingReservationId, 
      operator_name: operator_name,
      scheduled_tour_id: this.options.scheduled_tour_id
    })
    
    if @model.cancelled is true
      $(@el).addClass('reservation-cancelled')
      @$('.group-size').addClass('reservation-cancelled')
      @$('.cancel-reservation').hide()
      @$('.edit-reservation').hide()
      @$('.uncancel-reservation').show()  
    
    if this.options.tour_cancelled is true
      @$('.uncancel-reservation').hide() 
    
    if this.options.selected
      @toggleDetails()    
    @

  confirmUncancel: ->
    reservation = new Reservation(@model)
    reservation.uncancel((response) =>
      if response is true
        Backbone.eventHandler.trigger('reservation:uncancelled')
      else
        alert 'Could not uncancel reservation. Contact support'
    )
    return false
   
  toggleEditForm: (e) ->
    @$('#reservation-info').toggle()
    @$('#edit-reservation').toggle()
    e.stopImmediatePropagation()
    e.preventDefault()
    return false
     
  toggleConfirmCancelation: ->
    @$('#cancel-confirm-dialog').toggle()
    @$('.edit-reservation').toggle()
    @$('.cancel-reservation').toggle()
    return false

  cancelReservation: ->
    reservation = new Reservation(@model)
    reservation.cancel((response) =>
      if response is true
        Backbone.eventHandler.trigger('reservation:cancelled')
      else
        alert 'Could not cancel reservation. Contact support'
    )

  toggleDetails: ->
    @$('.reservation-details').toggle()
    if @$('.reservation-details').css('display') == 'none'
      $(@el).removeClass('reservation-selected')
    else
      $(@el).addClass('reservation-selected')

  save: ->
    reservation = new Reservation({id: @model.id, silent: true})
    reservation.fetch()
    reservation.save(@reservationData(), {
      error: (model, response) =>
        @$('#errors').html "<p class=error>#{response}</p>"
      success: =>
        Backbone.eventHandler.trigger('reservation:updated', @model.id)
        return false
    })
    
  reservationData: ->
    id = @$("input[name='id']").val()
    scheduled_tour_id = @$("input[name='scheduled_tour_id']").val()
    contact_name = @$("input[name='contact_name']").val()
    phone = @$("input[name='phone']").val()
    email = @$("input[name='email']").val()
    people = @$("input[name='number_of_people']").val()
    place_of_stay = @$("input[name='place_of_stay']").val()
    comments = @$("textarea[name='comments']").val()
    {
      id: id, 
      scheduled_tour_id: scheduled_tour_id, 
      contact_name: contact_name, 
      phone: phone, 
      email: email, 
      number_of_people: people, 
      place_of_stay: place_of_stay,
      comments: comments
    }
