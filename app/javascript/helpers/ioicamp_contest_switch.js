export function ioicampContestDashboardMain(){
  let SWITCH = document.getElementById('display_switch');

  SWITCH.onchange = function() {
    update(SWITCH.checked);
  };
  update(SWITCH.checked);

  function update(state) {
    const ele = $('.ioicamp-dashboard-switch');
    if (!state) {
      ele.removeClass('dashboard-show-score');
      ele.addClass('dashboard-show-penalty');
    } else {
      ele.removeClass('dashboard-show-penalty');
      ele.addClass('dashboard-show-score');
    }
  }

}
