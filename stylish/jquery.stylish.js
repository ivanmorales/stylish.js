// Generated by CoffeeScript 1.6.2
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

(function($, window) {
  var Stylish, selectors, templates;

  selectors = {
    modeClass: 'stylish-mode',
    wrapperClass: 'stylish-wrapper',
    selectorClass: 'input-selector'
  };
  templates = {
    hoverWrapper: "<div class=\"" + selectors.wrapperClass + "\"></div>",
    dialog: "<div class=\"stylish popover bottom\">\n	<div class=\"arrow\"></div>\n\n	<div class=\"popover-content\">\n		<small class=\"muted size\"></small>\n		<p>Selector</p>\n		<input type=\"text\" class=\"" + selectors.selectorClass + " input-medium pull-left\" />\n		<div class=\"btn-toolbar pull-left selector-level\">\n			<div class=\"btn-group\">\n				<a class=\"btn btn-mini select-up\" href=\"#\"><i class=\"icon-circle-arrow-up\"></i></a>\n				<a class=\"btn btn-mini select-down\" href=\"#\"><i class=\"icon-circle-arrow-down\"></i></a>\n			</div>\n		</div>\n		<textarea rows=\"3\" class=\"input-large\"></textarea>\n		<div class=\"text-center\">\n			<button class=\"btn btn-save\">Save</button>\n		</div>\n	</div>\n</div>"
  };
  Stylish = (function() {
    Stylish.prototype.active = false;

    Stylish.prototype.editing = false;

    Stylish.prototype.settings = {};

    Stylish.prototype.$container = void 0;

    Stylish.prototype.$element = void 0;

    Stylish.prototype.$wrapper = void 0;

    Stylish.prototype.$dialog = void 0;

    function Stylish(container, options) {
      this.changeLevel = __bind(this.changeLevel, this);
      this.displayEditor = __bind(this.displayEditor, this);
      this.displayOver = __bind(this.displayOver, this);
      this.getCompleteSelector = __bind(this.getCompleteSelector, this);      this.init(container, options);
    }

    Stylish.prototype.init = function(container, options) {
      var active;

      if (typeof options === 'string') {
        options = {
          post: options
        };
      }
      this.$container = $(container);
      if (this.$container.is(document) || this.$container.is(window)) {
        this.$container = $('body');
      }
      this.$container.append(templates.hoverWrapper);
      this.$container.append(templates.dialog);
      this.$wrapper = $(this.$container).children("." + selectors.wrapperClass);
      this.$dialog = $(this.$container).children('.stylish.popover');
      this.settings = $.extend({}, this.defaults, options);
      active = true;
      this.$container.addClass(selectors.modeClass);
      this.$container.on('mouseover', '*', this.displayOver);
      this.$container.on('click', '*', this.displayEditor);
      return this.$dialog.on('click', '.selector-level .btn', this.changeLevel);
    };

    Stylish.prototype.getSelector = function($element) {
      var classNames, id, selector;

      selector = $element[0].nodeName;
      id = $element.attr('id');
      classNames = $element.attr('class');
      if (id) {
        selector += "#" + id;
      }
      if (classNames) {
        selector += "." + ($.trim(classNames).replace(/\s/gi, '.'));
      }
      return selector.toLowerCase();
    };

    Stylish.prototype.getCompleteSelector = function($element, level) {
      var current, parents,
        _this = this;

      parents = $element.parents().map(function(index, element) {
        if (index < level) {
          return _this.getSelector($(element));
        }
      }).get().reverse().join(' ');
      current = this.getSelector($element);
      return ("" + parents + " " + current).replace("." + selectors.modeClass, '');
    };

    Stylish.prototype.on = function() {
      this.active = true;
      return this.$wrapper.show();
    };

    Stylish.prototype.off = function() {
      this.active = false;
      return this.$wrapper.hide();
    };

    Stylish.prototype.toggle = function() {
      if (this.active) {
        return this.off();
      } else {
        return this.on();
      }
    };

    Stylish.prototype.destroy = function() {
      this.$wrapper.remove();
      this.$container.off('mouseover', '*', this.displayOver);
      return this.$container.data('stylish', null);
    };

    Stylish.prototype.displayOver = function(e) {
      var $this;

      if (!this.active || this.editing) {
        return;
      }
      $this = $(e.target);
      this.$wrapper.width($this.width());
      this.$wrapper.height($this.height());
      this.$wrapper.offset($this.offset());
      return this.$wrapper.show();
    };

    Stylish.prototype.displayEditor = function(e) {
      var $this;

      e.preventDefault();
      e.stopPropagation();
      if (!this.active) {
        return;
      }
      $this = $(e.target);
      if (this.editing) {
        if ($this.is('.stylish.popover') || $this.parents('.stylish.popover').size() > 0) {
          return;
        } else {
          this.editing = false;
          this.$element = null;
          this.$dialog.hide();
          return;
        }
      }
      this.editing = true;
      this.$element = $this;
      this.$dialog.find("." + selectors.selectorClass).val(this.getCompleteSelector($this, 0));
      this.$dialog.find('.size').html("" + ($this.width()) + "px x " + ($this.height()) + "px");
      return this.$dialog.show().offset({
        top: $this.offset().top + $this.height() + 7,
        left: $this.offset().left + 15
      });
    };

    Stylish.prototype.changeLevel = function(e) {
      var $this, level;

      $this = $(e.currentTarget);
      level = this.$element.data('level') || 0;
      if ($this.is('.select-up')) {
        if (level < this.$element.parents().size()) {
          level++;
        }
      } else {
        if (level > 0) {
          level--;
        }
      }
      this.$dialog.find("." + selectors.selectorClass).val(this.getCompleteSelector(this.$element, level));
      return this.$element.data('level', level);
    };

    return Stylish;

  })();
  $.fn.stylish = function(options) {
    return this.each(function() {
      var data, plugin;

      data = $(this).data('stylish');
      if (data === void 0) {
        plugin = new Stylish(this, options);
        return $(this).data('stylish', plugin);
      } else {
        if (typeof options === 'string') {
          return data[options]();
        }
      }
    });
  };
  Stylish.prototype.defaults = {
    post: void 0
  };
  return void 0;
})(jQuery, window);

/*
//@ sourceMappingURL=jquery.stylish.map
*/