(($, window) ->
	selectors =
		modeClass: 'stylish-mode'
		wrapperClass: 'stylish-wrapper'
		inputSelectorClass: 'input-selector'
		inputStyleClass: 'input-style'

	templates =
		hoverWrapper:
			"""
				<div class="#{selectors.wrapperClass}"></div>
			"""
		dialog:
			"""
				<div class="stylish popover bottom">
					<div class="arrow"></div>

					<div class="popover-content">
						<small class="muted size"></small>
						<p>Selector</p>
						<input type="text" class="#{selectors.inputSelectorClass} input-medium pull-left" />
						<div class="btn-toolbar pull-left selector-level">
							<div class="btn-group">
								<a class="btn btn-mini select-up" href="#"><i class="icon-circle-arrow-up"></i></a>
								<a class="btn btn-mini select-down" href="#"><i class="icon-circle-arrow-down"></i></a>
							</div>
						</div>
						<textarea rows="3" class="#{selectors.inputStyleClass} input-large"></textarea>
						<div class="text-center">
							<button class="btn btn-save">Save</button>
						</div>
					</div>
				</div>
			"""

	class Stylish
		active: false
		editing: false
		settings: {}
		$container: undefined
		$element: undefined
		$wrapper: undefined
		$dialog: undefined

		constructor: (container, options) ->
			@init(container, options)

		# Initialize
		init: (container, options) ->
			# Assign post url for data
			if typeof options is 'string'
				options =
					post: options

			# Stablish the settings
			@settings = $.extend({}, @defaults, options)
			throw Error('You need to define the \'post\' parameter.') unless @settings.post

			# Initialize jQuery elements
			@$container = $(container)

			# Correct element
			if @$container.is(document) or @$container.is(window)
				@$container = $('body')

			@$container
				.append(templates.hoverWrapper)
				.append(templates.dialog)
			@$wrapper = $(@$container).children(".#{selectors.wrapperClass}")
			@$dialog = $(@$container).children('.stylish.popover')
			
			active = true
			
			@$container.addClass(selectors.modeClass)
			@$container.on('mouseover', '*', @displayOver)
			@$container.on('click', '*', @displayEditor)
			@$dialog.on('click', '.selector-level .btn', @changeLevel)
			@$dialog.on('click', '.btn-save', @saveStyles)

			$.ajax
				url: @settings.post
				data: { json: 1 }
				type: 'GET'
				success: @setStyleData

		# Utilities
		getSelector: ($element) ->
			selector = $element[0].nodeName
			id = $element.attr('id')
			classNames = $element.attr('class')

			selector += "##{id}" if id
			selector += ".#{$.trim(classNames).replace(/\s/gi, '.')}" if classNames

			selector.toLowerCase()
		getCompleteSelector: ($element, level) =>
			parents = $element
							.parents()
							.map((index, element) => @getSelector($(element)) if index < level)
							.get()
							.reverse()
							.join(' > ')
			current = @getSelector($element)

			selector = if parents then "#{parents} > #{current}" else "#{current}"

			selector.replace(".#{selectors.modeClass}", '')
		css2Json: (cssText) ->
			obj = {}

			attributes = cssText.replace('\n', '').split(';')
			attributes.pop()	# Remove the last element, because it's empty
			for line in attributes
				index = line.indexOf(':')
				attribute = $.trim(line.substring(0, index))
				value = $.trim(line.substr(index + 1)).replace(';', '')

				obj[attribute] = value

			obj
		json2Css: (cssJson) ->
			style = ""
			for attribute, value of cssJson
				style += "#{attribute}: #{value};\n"

			style

		# Actions
		on: ->
			@active = true
			@$wrapper.show()
		off: ->
			@active = false
			@$wrapper.hide()
		toggle: ->
			if @active then @off() else @on()
		destroy: ->
			@$wrapper.remove()
			@$container.off('mouseover', '*', @displayOver)
			@$container.off('click', '*', @displayEditor)
			@$dialog.off('click', '.selector-level .btn', @changeLevel)
			@$dialog.off('click', '.btn-save', @saveStyles)
			@$container.data('stylish', null)

		# AJAX
		setStyleData: (styles) ->
			for selector, style of styles
				data = $(selector).data('style')
				if not (data instanceof Array)
					data = []
				data.push({ selector: selector, style: style })
				$(selector).data('style', data)

			undefined

		# Events
		displayOver: (e) =>
			return if not @active or @editing

			$this = $(e.target)

			@$wrapper.width($this.outerWidth())
			@$wrapper.height($this.outerHeight())
			@$wrapper.offset($this.offset())

			@$wrapper.show()
		displayEditor: (e) =>
			e.preventDefault()
			e.stopPropagation()
			return unless @active

			$this = $(e.target)

			if @editing
				if $this.is('.stylish.popover') or $this.parents('.stylish.popover').size() > 0
					return
				else
					@editing = false
					@$element = null
					@$dialog.hide()
					return

			@editing = true
			@$element = $this

			if @$element.data('style')
				styles = @$element.data('style')
				selector = styles[0].selector
				styleText = @json2Css(styles[0].style)
			else
				selector = @getCompleteSelector($this, 0)
				styleText = ""
			
			@$dialog.find(".#{selectors.inputSelectorClass}").val(selector)
			@$dialog.find('.size').html("#{$this.width()}px x #{$this.height()}px")
			@$dialog.find(".#{selectors.inputStyleClass}").val(styleText)
			@$dialog
				.show()
				.offset	# TODO: Improve calculation of the location for the popover
					top: $this.offset().top + $this.height() + 7
					left: $this.offset().left + 15	# Calculate position for top arrow

		changeLevel: (e) =>
			$this = $(e.currentTarget)
			level = @$element.data('level') or 0

			if $this.is('.select-up')
				level++ if level < @$element.parents().size()
			else
				level-- if level > 0

			@$dialog.find(".#{selectors.inputSelectorClass}").val(@getCompleteSelector(@$element, level))
			@$element.data('level', level)
		saveStyles: (e) =>
			cssText = @$dialog.find(".#{selectors.inputStyleClass}").val().replace('\n', ' ')
			selector = @$dialog.find(".#{selectors.inputSelectorClass}").val()
			value = @css2Json(cssText)

			$.ajax
				url: @settings.post
				data:
					selector: selector
					value: value
				type: 'POST'
				success: ->
					$(selector).css(value)
				error: ->
					# TODO: Display error
			

	# Define plugin
	$.fn.stylish = (options) ->
		@each ->
			data = $(this).data('stylish') 
			if data is undefined
				plugin = new Stylish(this, options)
				$(this).data('stylish', plugin)
			else
				if typeof options is 'string'
					data[options]()

	Stylish::defaults =
		post: undefined

	undefined
)(jQuery, window)