window.Reservation = class Reservation extends Backbone.Model
  urlRoot: '/reservations'

  validate: (attrs) ->
    if attrs.contact_name is ''
      return window.ReservationErrors.contactEmpty
    unless attrs.phone is '' or /[\s|\d]+/.test(attrs.phone)
      return window.ReservationErrors.incorrectPhoneFormat
    if attrs.email is ''
      return window.ReservationErrors.emailEmpty
    unless /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/.test(attrs.email)
      return window.ReservationErrors.incorrectEmailFormat
    if attrs.number_of_people is ''
      return window.ReservationErrors.numberOfPeopleEmpty
    return undefined

  force: (callback) ->
    validation = @validate(@.attributes)
    if validation is undefined
      request = $.ajax({url: '/reservations/force_create', type: 'POST', data: {reservation: @.attributes}})
      request.done( => callback(true))
      request.fail( => callback(false))
    else
      callback(false)

  cancel: (callback) ->
    request = $.ajax({url: "/reservations/#{@.get('id')}/cancel", type: 'POST', data: {id: @.get('id')}})
    request.done( => callback(true))
    request.fail( => callback(false))
  
  uncancel: (callback) ->
    request = $.ajax({url: "/reservations/#{@.get('id')}/uncancel", type: 'POST', data: {id: @.get('id')}})
    request.done( => callback(true))
    request.fail( => callback(false))

window.ReservationCollection = class ReservationCollection extends Backbone.Model
  url: '/reservations'

window.ScheduledTour = class ScheduledTour extends Backbone.Model
  urlRoot: '/scheduled_tours'

  cancel: (callback) ->
    request = $.ajax({url: "/scheduled_tours/#{@.get('id')}/cancel", type: 'POST', data: {id: @.get('id')}})
    request.done( => callback(true))
    request.fail( => callback(false))
    
  uncancel: (callback) ->
    request = $.ajax({url: "/scheduled_tours/#{@.get('id')}/uncancel", type: 'POST', data: {id: @.get('id')}})
    request.done( => callback(true))
    request.fail( => callback(false))

  comment: (text, callback) ->
    request = $.ajax({url: "/scheduled_tours/#{@.get('id')}/comment", type: 'POST', data: {comment: text}})
    request.done( => callback(true))
    request.fail( => callback(false))
    
  isCancelled: ->
    cancelled = if @.get('cancelled') is true then true else false
    cancelled

  isAvailableOnApi: ->
    available = if @.get('available_on_api') is true then true else false
    available

  totalReservations: ->
    return 0 if @.get('reservations').length is 0
    notCancelled = _.filter(@.get('reservations'), (it) ->
      it.cancelled is false
    )
    _.reduce(_.pluck(notCancelled, 'number_of_people'), ((a, b) -> a + b), 0)

window.ScheduledTourCollection = class ScheduledTourCollection extends Backbone.Collection
  url: '/scheduled_tours'

window.CatalogDayCollection = class CatalogDayCollection extends Backbone.Collection
  model: ScheduledTour
  url: -> '/tour_operators/catalog?date=' + @date

  initialize: (models, options) ->
    @date = options.date

window.CalendarReservation = class CalendarReservation extends Backbone.Model

window.CalendarReservationCollection = class CalendarReservationCollection extends Backbone.Collection
  model: CalendarReservation
  url: -> "/tour_operators/dates?start_month=#{@startMonth}&start_year=#{@startYear}&months=#{@months}"

  initialize: (models, options) ->
    @startMonth = options.startMonth
    @startYear = options.startYear
    @months = options.months

window.OnTheFlyTour = class OnTheFlyTour extends Backbone.Model
  urlRoot: '/scheduled_tours'

  validate: (attrs) ->
    if attrs.product is ''
      return window.ScheduledTourErrors.productEmpty
    if attrs.date is ''
      return window.ScheduledTourErrors.dateEmpty
    if attrs.reservation.contact_name is ''
      return window.ReservationErrors.contactEmpty
    unless attrs.reservation.phone is '' or /[\s|\d]+/.test(attrs.reservation.phone)
      return window.ReservationErrors.incorrectPhoneFormat
    if attrs.reservation.email is ''
      return window.ReservationErrors.emailEmpty
    unless /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/.test(attrs.reservation.email)
      return window.ReservationErrors.incorrectEmailFormat
    if attrs.reservation.number_of_people is ''
      return window.ReservationErrors.numberOfPeopleEmpty
    return undefined

window.Product = class Product extends Backbone.Model

window.ProductCollection = class ProductCollection extends Backbone.Collection
  model: Product
  url: '/tour_operators/products'


