//= require actioncable
//= require submission_show

this.App || (this.App = {});

var protocol = location.protocol.match(/^https/) ? 'wss' : 'ws';

App.cable = ActionCable.createConsumer(`${protocol}:${location.host}/cable`);

// id can be integer or array of integers
this.subscribeSubmission = function(id, onReceive) {
  return App.cable.subscriptions.create({
    channel: "SubmissionChannel",
    id: id
  }, {
    received: onReceive
  });
};

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
