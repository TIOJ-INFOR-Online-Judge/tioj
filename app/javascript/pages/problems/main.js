import { buttonCheckboxSetup } from '../../helpers/button_checkbox_setup';

function setSpecjudgeVisibility(val) {
  $('.visibility-specjudge').hide();
  $('.visibility-specjudge-' + val).show();
}

function setInterlibVisibility(val) {
  $('.visibility-interlib').hide();
  $('.visibility-interlib-' + val).show();
}

export function initProblemForm() {
  $(document).on('nested:fieldRemoved',function(event){
    event.field.find("input").removeAttr("min max required");
  });
  buttonCheckboxSetup();

  setInterlibVisibility($('#problem_interlib_type').val());
  setSpecjudgeVisibility($('#problem_specjudge_type').val());
  $('#problem_interlib_type').on('change', function() {
    setInterlibVisibility(this.value);
  });
  $('#problem_specjudge_type').on('change', function() {
    setSpecjudgeVisibility(this.value);
  });
}