$.widget(
'jj.item_selector',
// jQuery.Widget, // this is default
(function() {
	var PANEL = 'itemSelectorPanel';

	return {
		_create: function() {
			// Take the panel outside our content box and put it on
			// the body so it can be dragged anywhere
			this.options[PANEL].element.appendTo('body');
			// On click, show the panel
			this.element.click(function() {
				// Unshow all other item selectors on the page
				$('.jj-widget .item_selector').
				this.options[PANEL].show();
			}.bind(this));
		}
	};
})());