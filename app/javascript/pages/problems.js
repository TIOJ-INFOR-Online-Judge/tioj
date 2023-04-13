// Bottom menu in Problems#Show
function toggleChevron(e) {
  return $(e.target).prev('.panel-heading').find('i.indicator').toggleClass('glyphicon-chevron-down glyphicon-chevron-up');
}

function updateQuickSubmit() {
  var prob_id = $(this).val();
  var link = '#';
  if (prob_id !== '') {
    link = `problems/${prob_id}/submissions/new`;
    if (location.pathname.slice(-1) === '/') {
      link = '../' + link;
    }
  }
  $('#quick_submit').attr('href', link);
}

$(() => {
  $('#lmenu').hide();
  $('#unfold').on('click', function() {
    $('#unfold').hide();
    $('#lmenu').show();
  });
  $('#fold').on('click', function() {
    $('#lmenu').hide();
    $('#unfold').show();
  });
  $('#collapseLimit').on('hidden.bs.collapse', toggleChevron);
  $('#collapseLimit').on('shown.bs.collapse', toggleChevron);
  $('#quick_prob_id').on('input', updateQuickSubmit);
  $('#quick_prob_id').trigger('input');
  $('#toggle-solution-tag').on('click', function() {
    $(this).text(($(this).hasClass('active') ? 'Show' : 'Hide') + ' solution-related tags');
    $('.solution-tag').toggleClass('no-display');
    return $(this).toggleClass('active');
  });
});
