function ioicamp_contest_dashboard_main(){

	let SWITCH = document.getElementById('display_switch')
	let TABLE = document.querySelector("table.dashboard-table")

	SWITCH.onchange = function() {
		enable = SWITCH.parentNode.getAttribute('class').includes('switch-on');
		update(enable);
	};

	update(true);

	function update(state) {
		if (!state) {
			TABLE.classList.add('dashboard-show-penalty');
			TABLE.classList.remove('dashboard-show-score');
		} else {
			TABLE.classList.remove('dashboard-show-penalty');
			TABLE.classList.add('dashboard-show-score');
		}
	}

}
