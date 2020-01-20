/* Unused code 
function init_code_copy_script() {
	document.addEventListener("DOMContentLoaded", function () {

		let code = document.getElementById("submission_code")
		let btn = document.getElementById("copy_btn")

		btn.addEventListener('click', (e) => {
			let range = document.createRange()
			range.selectNode(code)
			window.getSelection().addRange(range)
			try {
				if (document.execCommand('copy')) 
					generate_success_notify()
				else 
					generate_failed_notify()
			} catch (err) {
				generate_error_notify(err)
			}
			window.getSelection().removeAllRanges()
		})

		function generate_success_notify() {
			$.notify({
				title: '<strong>Geez</strong>',
				message: "Successful copied!"
			}, {
				type: 'success',
				animate: {
					enter: 'animated fadeInLeft',
					exit: 'animated fadeOutRight'
				},
				placement: {
					from: "bottom",
					align: "right"
				},
				offset: 20,
				spacing: 10,
				z_index: 1031,
				newest_on_top: true,
			})
		}

		function generate_failed_notify() {
			$.notify({
				title: '<strong>Geez</strong>',
				message: "Copy failed!"
			},{
				type: 'danger',
				animate: {
					enter: 'animated fadeInLeft',
					exit: 'animated fadeOutRight'
				},
				placement: {
					from: "bottom",
					align: "right"
				},
				offset: 20,
				spacing: 10,
				z_index: 1031,
				newest_on_top: true,
			});
		}

		function generate_error_notify(err) {
			$.notify({
				title: '<strong>Geez</strong>',
				message: err
			},{
				type: 'danger',
				animate: {
					enter: 'animated fadeInLeft',
					exit: 'animated fadeOutRight'
				},
				placement: {
					from: "bottom",
					align: "right"
				},
				offset: 20,
				spacing: 10,
				z_index: 1031,
				newest_on_top: true,
			});
		}

	});
}
*/
