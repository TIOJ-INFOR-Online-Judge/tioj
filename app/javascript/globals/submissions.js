var toggleChevron = function(e) {
  if (this.classList.contains('d-none')) {
    e.preventDefault();
  } else {
    $(e.target).prev('.card-header').find('span.indicator').toggleClass('bi-chevron-down bi-chevron-up');
  }
};

var immediateToggle = function(e) {
  if (!this.classList.contains('d-none')) {
    $(e.target).toggle();
  }
};

var noPropagate = function(e) {
  e.stopPropagation();
};

$(function() {
  $('#collapseSubtask').on('hidden.bs.collapse shown.bs.collapse', toggleChevron);
  $('#collapseTestdata').on('hidden.bs.collapse shown.bs.collapse', toggleChevron);
  $('.collapse-no-anim.collapse').on('hide.bs.collapse show.bs.collapse', toggleChevron);
  $('.collapse-no-anim.collapse').on('hide.bs.collapse show.bs.collapse', immediateToggle);
  return $('.collapse-no-anim.collapse').on('hidden.bs.collapse shown.bs.collapse', noPropagate);
});
