$.widget(
'jj.item_selector',
$.extend(JJ.WidgetBase, (function() {
	var PANEL = 'itemSelectorPanel';

	return {
		_create: function() {
			// Take the panel outside our content box and put it on
			// the body so it can be dragged anywhere
			this.subwidget(PANEL).element.appendTo('body');
			// On click, show the panel
			this.element.find('.selector-button').click(function() {
				// Unshow all other item selectors on the page
				$('.jj-widget.item_selector').each(function(i, el) {
					$(el).data("jj-item_selector").show(false);
				});
				this.subwidget(PANEL).show();
			}.bind(this));
		},

		show: function(doShow) {
			this.subwidget(PANEL).show(doShow);
		}
	};
})()));