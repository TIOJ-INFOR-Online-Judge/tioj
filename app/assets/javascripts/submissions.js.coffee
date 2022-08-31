# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#= require actioncable

@App ||= {}

protocol = if location.protocol.match(/^https/)
  'wss'
else
  'ws'

App.cable = ActionCable.createConsumer("#{protocol}:#{location.host}/cable")

# id can be integer or array of integers
@subscribeSubmission = (id, onReceive) ->
  App.cable.subscriptions.create {channel: "SubmissionChannel", id: id},
    received: onReceive

toggleChevron = (e) ->
  if this.classList.contains('no-display')
    e.preventDefault()
  else
    $(e.target)
        .prev('.panel-heading')
        .find('i.indicator')
        .toggleClass('glyphicon-chevron-down glyphicon-chevron-up')

immediateToggle = (e) ->
  if not this.classList.contains('no-display')
    $(e.target).toggle()

noPropagate = (e) ->
  e.stopPropagation()

jQuery ->
  $('#collapseSubtask').on('hidden.bs.collapse shown.bs.collapse', toggleChevron)
  $('#collapseTestdata').on('hidden.bs.collapse shown.bs.collapse', toggleChevron)
  $('.collapse-no-anim.collapse').on('hide.bs.collapse show.bs.collapse', toggleChevron)
  $('.collapse-no-anim.collapse').on('hide.bs.collapse show.bs.collapse', immediateToggle)
  $('.collapse-no-anim.collapse').on('hidden.bs.collapse shown.bs.collapse', noPropagate)
  $("#quick_submit").click ->
    prob_id = $('#quick_prob_id').val()
    if prob_id == ""
      return

    window.location.href = "/problems/#{prob_id}/submissions/new"

