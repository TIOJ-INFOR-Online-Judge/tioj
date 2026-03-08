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

  let prog_stage_list = $('#problem_problem_prog_stage_list').val();

  setGroupVisibility('interlib', $('#problem_interlib_type').val());
  setGroupVisibility('specjudge', $('#problem_specjudge_type').val());
  setGroupVisibility('summary', $('#problem_summary_type').val());
  setGroupVisibility('problem-prog', $('#problem__problem_prog_enabled').is(':checked') ? '1' : '0');
  $('#problem_interlib_type').on('change', function() {
    setGroupVisibility('interlib', this.value);
  });
  $('#problem_specjudge_type').on('change', function() {
    setGroupVisibility('specjudge', this.value);
  });
  $('#problem_summary_type').on('change', function() {
    setGroupVisibility('summary', this.value);
  });
  $('#problem__problem_prog_enabled').on('change', function() {
    setGroupVisibility('problem-prog', this.checked ? '1' : '0');
    if (this.checked) {
      $('#problem_problem_prog_stage_list').val(prog_stage_list);
    } else {
      prog_stage_list = $('#problem_problem_prog_stage_list').val();
      $('#problem_problem_prog_stage_list').val('');
    }
  });
}