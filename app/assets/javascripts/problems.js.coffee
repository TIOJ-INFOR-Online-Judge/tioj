# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Bottom menu in Problems#Show
toggleChevron = (e) ->
  $(e.target)
      .prev('.panel-heading')
      .find("i.indicator")
      .toggleClass('glyphicon-chevron-down glyphicon-chevron-up')

jQuery ->
  $('#lmenu').hide()
  $('#unfold').click ->
    $('#unfold').hide()
    $('#lmenu').show()
  $('#fold').click ->
    $('#lmenu').hide()
    $('#unfold').show()
  $('#collapseLimit').on('hidden.bs.collapse', toggleChevron)
  $('#collapseLimit').on('shown.bs.collapse', toggleChevron)
  $('#toggle-solution-tag').click ->
    $(this).text((if $(this).hasClass('active') then 'Show' else 'Hide') + ' solution-related tags')
    $('.solution-tag').toggleClass('no-display');
    $(this).toggleClass('active');
