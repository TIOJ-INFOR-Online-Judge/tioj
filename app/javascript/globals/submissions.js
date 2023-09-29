var toggleChevron = function(e) {
  if (this.classList.contains('no-display')) {
    e.preventDefault();
  } else {
    $(e.target).prev('.panel-heading').find('i.indicator').toggleClass('glyphicon-chevron-down glyphicon-chevron-up');
  }
};

var immediateToggle = function(e) {
  if (!this.classList.contains('no-display')) {
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