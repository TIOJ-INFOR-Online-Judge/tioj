function ioicamp_contest_dashboard_main(){

	let _debug = false

	function debug(...args) {
		if (_debug === false) return
		console.log(...args)
	}

	debug("ioicamp_contest_dashboard_refresh.js is loaded.")
	let SWITCH = document.getElementById('display_switch')
	let TABLE = document.querySelector("table.dashboard-table")

	debug(SWITCH);

	SWITCH.onchange = function() {
		enable = SWITCH.parentNode.getAttribute('class').includes('switch-on');
		debug(`SWITCH.onchange(), get enable = ${enable}`)

		update(enable);
	};

	update(true);

	function update(state) {
		console.log(TABLE);
		if (!state) {
			TABLE.classList.add('dashboard-show-penalty');
			TABLE.classList.remove('dashboard-show-score');
		} else {
			TABLE.classList.remove('dashboard-show-penalty');
			TABLE.classList.add('dashboard-show-score');
		}
	}

}
