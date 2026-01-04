export function buttonCheckboxSetup() {

$('.button-checkbox').each(function () {

	// Settings
	var $widget = $(this),
		$button = $widget.find('button'),
		$checkbox = $widget.find('input:checkbox'),
		color = $button.data('color'),
		settings = {
			on: {
				icon: 'bi bi-check-square'
			},
			off: {
				icon: 'bi bi-square'
			}
		};

	// Event Handlers
	$button.on('click', function () {
		$checkbox.prop('checked', !$checkbox.is(':checked'));
		$checkbox.triggerHandler('change');
		updateDisplay();
	});
	$checkbox.on('change', function () {
		updateDisplay();
	});

	// Actions
	function updateDisplay() {
		var isChecked = $checkbox.is(':checked');

		// Set the button's state
		$button.data('state', (isChecked) ? "on" : "off");

		// Set the button's icon
		$button.find('.state-icon')
			.removeClass()
			.addClass('state-icon ' + settings[$button.data('state')].icon);

		// Update the button's color
		if (isChecked) {
			$button
				.removeClass('btn-secondary')
				.addClass('btn-' + color + ' active');
		}
		else {
			$button
				.removeClass('btn-' + color + ' active')
				.addClass('btn-secondary');
		}
	}

	// Initialization
	function init() {

		updateDisplay();

		// Inject the icon if applicable
		if ($button.find('.state-icon').length == 0) {
			$button.prepend('<i class="state-icon ' + settings[$button.data('state')].icon + '"></i> ');
		}
	}
	init();
});

}
