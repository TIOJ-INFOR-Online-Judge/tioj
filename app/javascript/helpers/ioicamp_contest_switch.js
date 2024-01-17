export function ioicampContestDashboardMain(){
	let SWITCH = document.getElementById('display_switch')
	let TABLE = document.querySelector("table.dashboard-table")

	SWITCH.onchange = function() {
		update(SWITCH.checked);
	};

	function update(state) {
		if (!state) {
			TABLE.classList.remove('dashboard-show-score');
			TABLE.classList.add('dashboard-show-penalty');
		} else {
			TABLE.classList.remove('dashboard-show-penalty');
			TABLE.classList.add('dashboard-show-score');
		}
	}

}
