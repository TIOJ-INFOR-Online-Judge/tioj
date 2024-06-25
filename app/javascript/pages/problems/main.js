import { buttonCheckboxSetup } from '../../helpers/button_checkbox_setup';

function setGroupVisibility(type, val) {
  $('.visibility-' + type).hide();
  $('.visibility-' + type + '-' + val).show();
}

export function initProblemForm() {
  $(document).on('nested:fieldRemoved',function(event){
    event.field.find("input").removeAttr("min max required");
  });
  buttonCheckboxSetup();

  setGroupVisibility('interlib', $('#problem_interlib_type').val());
  setGroupVisibility('specjudge', $('#problem_specjudge_type').val());
  setGroupVisibility('proxyjudge', $('#problem_proxyjudge_type').val());
  setGroupVisibility('summary', $('#problem_summary_type').val());
  $('#problem_interlib_type').on('change', function() {
    setGroupVisibility('interlib', this.value);
  });
  $('#problem_specjudge_type').on('change', function() {
    setGroupVisibility('specjudge', this.value);
  });
  $('#problem_proxyjudge_type').on('change', function() {
    setGroupVisibility('proxyjudge', this.value);
  });
  $('#problem_summary_type').on('change', function() {
    setGroupVisibility('summary', this.value);
  });
}
