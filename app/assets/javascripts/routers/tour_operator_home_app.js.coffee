window.TourOperatorHomeApp = class TourOperator extends Backbone.Router

  initialize: (options) ->
    @locale = options.locale

  routes:
    ':date/:selected_tour_id': 'calendar',
    ':date/': 'calendar',
    ':date': 'calendar',
    '.*': 'calendar'

  views: {}
  
  calendar: (date, selected_tour_id) ->
    UrlState = Backbone.Model.extend({})
    urlState = new UrlState()
    if _.size(@views) == 0
      @views.tv = new ToursView({urlState: urlState, selected_tour_id: selected_tour_id})
      @views.tv.render()
      @views.cv = new CalendarView({urlState: urlState, locale: @locale, date: date})
      @views.cv.render()
      @views.tdv = new TourDetailView({urlState: urlState})
      @views.tdv.render()
      @views.otftv = new OnTheFlyTourView()
    else
      @views.tv.updateSelectedTourId(selected_tour_id)
      if date
        day = new Date(date + "T12:00:00+00:00")
        Backbone.eventHandler.trigger('date:changed', {date: day})
