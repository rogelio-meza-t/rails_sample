window.ToursView = class ToursView extends Backbone.View
  el: '#tours'

  initialize:(options) ->
    @collection = new CatalogDayCollection([], {date: $.datepicker.formatDate('yy-mm-dd', new Date())})
    Backbone.eventHandler.on('date:changed', @dateChanged, @)
    Backbone.eventHandler.on('tour:cancelled', @tourCancelled, @)
    Backbone.eventHandler.on('tour:uncancelled', @tourUncancelled, @)
    Backbone.eventHandler.on('tour:commented', @tourCommented, @)
    Backbone.eventHandler.on('reservation:added', @reservationChange, @)
    Backbone.eventHandler.on('reservation:cancelled', @reservationChange, @)
    Backbone.eventHandler.on('reservation:updated', @reservationChange, @)
    Backbone.eventHandler.on('reservation:uncancelled', @reservationChange, @)
    Backbone.eventHandler.on('onthefly:added', @onTheFlyTourAdded, @)
    @collection.bind('reset', @refreshTours, @)

  events: ->
    'click #tours-of-the-day section': 'scheduledTourSelected'
    'click #on-the-fly-tour': 'displayOnTheFlyTourForm'

  dateChanged: (payload) =>
    @$('#tours-of-the-day').html('')
    @currentDate = new Date(payload.date)
    @options.urlState.date = @currentDate
    if !@options.selected_tour_id
      app.navigate($.datepicker.formatDate('yy-mm-dd', @currentDate))
    
    @showPrettyDate(@currentDate)
    @collection.date = @currentDate
    @collection.fetch()

  tourCancelled: ->
    @collection.fetch()
    
  tourUncancelled: ->
    @collection.fetch()

  tourCommented: ->
    @collection.fetch()
    
  reservationChange: ->
    @collection.fetch()

  onTheFlyTourAdded: ->
    @collection.fetch()

  updateSelectedTourId: (id) ->
    @options.selected_tour_id = id
    
  refreshTours: ->
    @$('#tours-of-the-day').html ''
    _.each(@collection.models, (it) => @showTour it)
    if @options.selected_tour_id
      @$("#" + @options.selected_tour_id).click()

  showPrettyDate: (date) ->
    dayNumber = $.datepicker.formatDate('d', date)
    weekDay = $.datepicker.formatDate('DD', date)
    monthYear = $.datepicker.formatDate('MM yy', date)
    @$('#pretty-date h1').text(dayNumber)
    @$('#week-day').text(weekDay)
    @$('#month-year').text(monthYear)

  showTour: (tour) ->
    template = $('#tour-list-template').html()
    cancelled = if tour.isCancelled() is true then 'cancelled-tour' else ''
    available = if not tour.isAvailableOnApi() is true then 'unavailable-tour' else ''
    @$('#tours-of-the-day').append _.template(template, {tour: tour, cancelled: cancelled, reservations: tour.totalReservations(), available: available})
    
  scheduledTourSelected: (event) ->
    @$('#tours-of-the-day section').removeClass('selected')
    $(event.currentTarget).addClass('selected')
    id = $(event.currentTarget).attr('id')
    Backbone.eventHandler.trigger('tour:changed', {selected_tour: id})

  displayOnTheFlyTourForm: ->
    Backbone.eventHandler.trigger('onthefly:show', {date: @currentDate})
