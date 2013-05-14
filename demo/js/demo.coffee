(($, window) ->
	$(document).ready ->
		$("#main").stylish("scripts/stylish.php")
		$("#main").stylish('off')

		$('#toggle_stylish').on 'click', (e) ->
			$("#main").stylish('toggle')
)(jQuery, window)