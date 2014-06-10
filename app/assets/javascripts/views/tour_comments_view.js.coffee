window.TourCommentsView = class TourCommentsView extends Backbone.View
  className: 'tour-comments'
  
  initialize: (options) ->
    @model = options.model

  events: ->
    'click #show-edit-comments': 'toggleForm'
    'click #cancel-edit-comments': 'toggleForm'
    'click #submit-edit-comments': 'save'

  save: ->
    comments = @$("textarea[name='comments']").val()
    @model.comment(comments, (response) =>
      if response is true
        @model.fetch()
        Backbone.eventHandler.trigger('tour:commented', {scheduled_tour: @model.get('id')})
      else
        alert 'Could not update comment. Contact support'
    )
    
  render: ->
    template = $('#tour-comments-template').html()
    if !@model.get('comments')
      @model.set('comments', '', {silent: true})
    $(@el).html _.template(template, {model: @model})
    @

  toggleForm: ->
    @$('#edit-comments').toggle()
    @$('#comments-container').toggle()
    @$('#show-edit-comments').toggle()
    false
