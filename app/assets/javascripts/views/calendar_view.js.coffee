window.CalendarView = class CalendarView extends Backbone.View
  el: '#calendar'

  initialize:(options) ->
    @locale = options.locale
    startMonth = $.datepicker.formatDate('m', new Date())
    startYear = $.datepicker.formatDate('yy', new Date())
    @changeMonth(startYear, startMonth)
    Backbone.eventHandler.on('reservation:added', @reservationAdded, @)
    Backbone.eventHandler.on('reservation:cancelled', @refreshReservations, @)
    Backbone.eventHandler.on('reservation:uncancelled', @refreshReservations, @)
    Backbone.eventHandler.on('tour:cancelled', @refreshReservations, @)

  render: ->
    @showCalendar()

  showCalendar: ->
    day = if this.options.date then new Date(this.options.date + "T12:00:00+00:00") else new Date()
    @showCalendarOn(day)
    Backbone.eventHandler.trigger('date:changed', {date: day})

  showCalendarOn: (date) ->
    $.datepicker.setDefaults($.datepicker.regional['es']) if @locale is 'es'
    currentMonth = @$('#current-month')
    currentMonth.datepicker(
      onSelect: (date) -> Backbone.eventHandler.trigger('date:changed', {date: date})
      onChangeMonthYear: @changeMonth
      beforeShowDay: @beforeShowDay
    )
    currentMonth.datepicker('setDate', date)

  beforeShowDay: (date) =>
    currentDate = $.datepicker.formatDate('mm/dd/yy', date)
    scheduledTourDates = (@collection.models.reduce (p, it) ->
      #TODO: this should be a call to @buildDate(it.get('date'))
      #      but there is an scopes issue I can't get over
      theDate =new Date("#{it.get('date')}T12:00:00+00:00")
      fDate = $.datepicker.formatDate('mm/dd/yy', theDate)
      if (p.hasOwnProperty(fDate))
        if (it.get('cancelled'))
          p[fDate] += 1 
      else
        if (it.get('cancelled'))
          p[fDate] = 1
        else
          p[fDate] = 0
      p
    , {})
    if (scheduledTourDates.hasOwnProperty(currentDate))
      if scheduledTourDates[currentDate] > 0
        return [true, 'tour-scheduled has-cancelled', '']
      else 
        return [true, 'tour-scheduled', '']
    else
      return [true, '']

  reservationAdded: (payload) ->
    @refreshReservations(payload)

  refreshReservations: (payload) ->
    currentDate = @$('#current-month').datepicker('getDate')
    date = if payload and payload.date then @buildDate(payload.date) else @buildDate(currentDate)
    @collection.fetch()
    @showCalendarOn(date)

  refreshCalendar: ->
    @$('#current-month').datepicker('refresh')

  changeMonth: (year, month, inst) => 
    @collection = new CalendarReservationCollection([], {startMonth: month, startYear: year, months: 1})
    @collection.fetch()
    @collection.bind('reset', @refreshCalendar, @)

  buildDate: (dateParam) ->
    pad = (number) ->
      return "0#{number}" if number < 10
      "#{number}"

    #NOTE: This is an ugly hack to solve the timezone issue by taking UTC
    #      dates at noon and preventing the time-changes from shifting days
    date = new Date(dateParam)
    year  = date.getFullYear()
    month = date.getMonth() + 1
    days  = date.getDate()
    dateString = "#{year}-#{pad(month)}-#{pad(days)}"
    fullDate = "#{dateString}T12:00:00+00:00"
    new Date(fullDate)
