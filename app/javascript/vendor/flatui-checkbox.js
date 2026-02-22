/*
 * https://raw.githubusercontent.com/designmodo/Flat-UI/2.1.3/js/flatui-checkbox.js
 * Adapted to jQuery 3
 */
/* =============================================================
 * flatui-checkbox v0.0.3
 * ============================================================ */

!function ($) {

 /* CHECKBOX PUBLIC CLASS DEFINITION
  * ============================== */

  var Checkbox = function (element, options) {
    this.init(element, options);
  }

  Checkbox.prototype = {

    constructor: Checkbox

  , init: function (element, options) {
    var $el = this.$element = $(element)

    this.options = $.extend({}, $.fn.checkbox.defaults, options);
    $el.before(this.options.template);
    this.applyInputStyles();
    $el.on('change.checkbox', $.proxy(this.setState, this));
    this.setState();
  }

  , applyInputStyles: function () {
      this.$element.css({
        display: 'block',
        opacity: 0,
        zIndex: -1
      });
  }

  , setState: function () {
      var $el = this.$element
        , $parent = $el.closest('.checkbox');

        $parent.toggleClass('disabled', $el.prop('disabled'));
        $parent.toggleClass('checked', $el.prop('checked'));
    }

  , toggle: function () {
      var $el = this.$element
        , e = $.Event('toggle')

      if ($el.prop('disabled') == false) {
        $el.prop('checked', !$el.prop('checked'));
        this.setState();
        $el.trigger(e).trigger('change');
      }
    }

  , setCheck: function (option) {
      var $el = this.$element
        , checkAction = option == 'check' ? true : false
        , e = $.Event(option)

      $el.prop('checked', checkAction);
      this.setState();
      $el.trigger(e).trigger('change');
    }

  }


 /* CHECKBOX PLUGIN DEFINITION
  * ======================== */

  var old = $.fn.checkbox

  $.fn.checkbox = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('checkbox')
        , options = $.extend({}, $.fn.checkbox.defaults, $this.data(), typeof option == 'object' && option);
      if (!data) $this.data('checkbox', (data = new Checkbox(this, options)));
      if (option == 'toggle') data.toggle()
      if (option == 'check' || option == 'uncheck') data.setCheck(option)
      else if (option) data.setState();
    });
  }

  $.fn.checkbox.defaults = {
    template: '<span class="icons"><span class="first-icon fui-checkbox-unchecked"></span><span class="second-icon fui-checkbox-checked"></span></span>'
  }


 /* CHECKBOX NO CONFLICT
  * ================== */

  $.fn.checkbox.noConflict = function () {
    $.fn.checkbox = old;
    return this;
  }


 /* CHECKBOX DATA-API
  * =============== */

  $(document).on('click.checkbox.data-api', '[data-toggle^=checkbox], .checkbox', function (e) {
    var $checkbox = $(e.target);
    if (e.target.tagName == "A") return;

    var $target = $(e.target);
    if ($target.is(':checkbox')) return;

    var $checkbox = $target.hasClass('checkbox') ? $target : $target.closest('.checkbox');
    if ($checkbox.is('label')) return;

    e && e.preventDefault() && e.stopPropagation();
    $checkbox.find(':checkbox').first().checkbox('toggle').trigger('focus');
  });

  $(function () {
    $('[data-toggle="checkbox"]').each(function () {
      var $checkbox = $(this);
      $checkbox.checkbox();
    });
  });

}(window.jQuery);
