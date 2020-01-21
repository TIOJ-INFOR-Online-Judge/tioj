(() => {
	document.addEventListener("DOMContentLoaded", function () {

		let divs = document.querySelectorAll(".copy-group")

		for (let i in divs)
			initialize(divs[i])

		function initialize(div) {
			let btn = div.getElementsByClassName("copy-group-btn")[0]
			let code = div.getElementsByClassName("copy-group-code")[0]


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
		}

		function generate_success_notify() {
			$.notify({
				title: '<strong>Geez</strong>',
				message: "Successful copied!"
			}, {
				type: 'success',
				animate: {
					enter: 'animated fadeInLeft animate_speed_0_4s',
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
})()
