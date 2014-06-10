window.TourDetailView = class TourDetailView extends Backbone.View
  el: '#tour-details'

  initialize: ->
    @model = new ScheduledTour()
    @model.bind('change', @refreshInfo, @)
    Backbone.eventHandler.on('tour:changed', @fetchModel, @)
    Backbone.eventHandler.on('date:changed', @hideScreen, @)
    Backbone.eventHandler.on('reservation:cancelled', @reservationCancelled, @)
    Backbone.eventHandler.on('reservation:updated', @reservationUpdated, @)
    Backbone.eventHandler.on('reservation:uncancelled', @reservationCancelled, @)
    Backbone.eventHandler.on('onthefly:added', @fetchModel, @)
    $(@el).hide()

  events: ->
    'click #show-more-details': 'toggleDetails'
    'click .cancel-tour': 'cancelTour'
    'click .uncancel-tour': 'uncancelTour'
    'click .confirm-cancelation': 'confirmCancellation'
    'click .do-not-cancel': 'doNotCancel'
    'click .confirm-uncancelation': 'confirmUncancellation'
    'click .do-not-uncancel': 'doNotUncancel'
    'click #print-tour': 'showPrintDialog'

  showPrintDialog: ->
    template = $('#print-tour-template').html()
    printWindow = window.open('', 'thePopup', 'width=650,height=350,scrollbars=1,location=0')
    printWindow.document.getElementsByTagName('body')[0].innerHTML = '';
    printWindow.document.write(_.template(template, {model: @model}))
    printWindow.focus()
    setTimeout( ->
      printWindow.print()
    , 2000)

  fetchModel: (payload) ->
    id = payload.selected_tour
    @model.set('id', id, {silent: true})
    @model.fetch()

  reservationCancelled: ->
    @model.fetch()
  
  reservationUpdated: (selected_rez_id) ->
    @model.fetch()
    @model.selected_rez_id = selected_rez_id

  refreshInfo: ->
    @options.urlState.selected_id = @model.id
    app.navigate($.datepicker.formatDate('yy-mm-dd', @options.urlState.date) + "/" + @model.id)
    template = $('#tour-details-template').html()
    $(@el).html _.template(template, {model: @model})
    $(@el).append new AddReservationView({model: @model}).render().el
    $(@el).append new ReservationListView({
      tour_cancelled: @model.get('cancelled'),
      selected_rez_id: @model.selected_rez_id,
      scheduled_tour_id: @model.id, 
      collection: @model.get('reservations')
    }).render().el
    $(@el).append new TourCommentsView({model: @model}).render().el
    @showStatus()
    $(@el).fadeIn()

  showStatus: ->
    if @model.get('cancelled') is true
      $(@el).addClass('cancelled-tour')
      @$('.cancel-tour').hide()
      @$('.add-reservation').hide()
    else
      $(@el).removeClass('cancelled-tour')
      @$('.uncancel-tour').hide()

  toggleDetails: ->
    @$('#more-details').toggle('200')
    return false

  hideScreen: (payload) ->
    $(@el).html ''
    $(@el).hide()

  cancelTour: ->
    template = $('#cancel-tour-template').html()
    @$('.cancel-tour').html _.template(template)
    
  uncancelTour: ->
    template = $('#uncancel-tour-template').html()
    @$('.uncancel-tour').html _.template(template)

  doNotCancel: ->
    @$('.cancel-tour').html ''
    _.delay(@showCancelButton, 500)
    
  doNotUncancel: ->
    @$('.uncancel-tour').html ''
    _.delay(@showUncancelButton, 500)

  showCancelButton: ->
    @$('.cancel-tour').text 'Cancel tour'

  showUncancelButton: ->
    @$('.uncancel-tour').text 'Uncancel tour'

  confirmCancellation: ->
    @model.cancel((response) =>
      if response is true
        @model.fetch()
        Backbone.eventHandler.trigger('tour:cancelled', {scheduled_tour: @model.get('id')})
      else
        alert 'Could not cancel tour. Contact support'
    ) 
    
  confirmUncancellation: ->
    @model.uncancel((response) =>
      if response is true
        @model.fetch()
        Backbone.eventHandler.trigger('tour:uncancelled', {scheduled_tour: @model.get('id')})
      else
        alert 'Could not uncancel tour. Contact support'
    )
