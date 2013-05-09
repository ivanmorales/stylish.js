(($, window) ->
	$(document).ready ->
		$("#main").stylish()
		$("#main").stylish('off')

		$('#toggle_stylish').on 'click', (e) ->
			$("#main").stylish('toggle')
)(jQuery, window)