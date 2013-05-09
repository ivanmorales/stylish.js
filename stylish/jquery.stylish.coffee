(($, window) ->
	selectors =
		modeClass: 'stylish-mode'
		wrapperClass: 'stylish-wrapper'
		selectorClass: 'input-selector'

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
						<input type="text" class="#{selectors.selectorClass} input-medium pull-left" />
						<div class="btn-toolbar pull-left selector-level">
							<div class="btn-group">
								<a class="btn btn-mini select-up" href="#"><i class="icon-circle-arrow-up"></i></a>
								<a class="btn btn-mini select-down" href="#"><i class="icon-circle-arrow-down"></i></a>
							</div>
						</div>
						<textarea rows="3" class="input-large"></textarea>
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

			# Initialize jQuery elements
			@$container = $(container)

			# Correct element
			if @$container.is(document) or @$container.is(window)
				@$container = $('body')

			@$container.append(templates.hoverWrapper)
			@$container.append(templates.dialog)
			@$wrapper = $(@$container).children(".#{selectors.wrapperClass}")
			@$dialog = $(@$container).children('.stylish.popover')

			# 
			@settings = $.extend({}, @defaults, options)
			# throw Error('You need to define the \'post\' parameter.') unless @settings.post
			
			active = true
			
			@$container.addClass(selectors.modeClass)
			@$container.on('mouseover', '*', @displayOver)
			@$container.on('click', '*', @displayEditor)
			@$dialog.on('click', '.selector-level .btn', @changeLevel)

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
							.join(' ')
			current = @getSelector($element)

			"#{parents} #{current}".replace(".#{selectors.modeClass}", '')

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
			@$container.data('stylish', null)

		# Events
		displayOver: (e) =>
			return if not @active or @editing

			$this = $(e.target)

			@$wrapper.width($this.width())
			@$wrapper.height($this.height())
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
			
			@$dialog.find(".#{selectors.selectorClass}").val(@getCompleteSelector($this, 0))
			@$dialog.find('.size').html("#{$this.width()}px x #{$this.height()}px")
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

			@$dialog.find(".#{selectors.selectorClass}").val(@getCompleteSelector(@$element, level))
			@$element.data('level', level)


	# Define plugin
	$.fn.stylish = (options) ->
		this.each ->
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