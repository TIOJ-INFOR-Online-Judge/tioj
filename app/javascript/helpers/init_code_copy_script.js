$(() => {
	$('.copy-group').each(function() {
		let btn = $(this).find('.copy-group-btn').first();
		let code = $(this).find('.copy-group-code').first();

		btn.on('click', () => {
			let text = code.text();
			if (navigator.clipboard) {
				navigator.clipboard.writeText(text).then(generateSuccessNotify).catch(generateFailedNotify);
			} else { // old deprecated method
				try {
					let tmp = $('<textarea>');
					$('body').append(tmp);
					tmp.val(text).trigger('select');
					if (document.execCommand('copy')) {
						generateSuccessNotify();
					} else {
						generateFailedNotify();
					}
					tmp.remove();
				} catch (err) {
					generateNotify(err, 'danger');
				}
			}
		});
	});

	function generateNotify(message, type) {
		$.notify({
			title: "<strong>Geez</strong>",
			message: message,
		}, {
			type: type,
			animate: {
				enter: 'animate__animated animate__fadeInLeft',
				exit: 'animate__animated animate__fadeOutRight',
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

	function generateSuccessNotify() {
		generateNotify("Successful copied!", 'success');
	}

	function generateFailedNotify() {
		generateNotify("Copy failed!", 'danger');
	}
});
