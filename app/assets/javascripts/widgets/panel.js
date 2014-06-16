$.widget(
'jj.panel',
$.extend(JJ.WidgetBase, (function() {
	var PANEL_ELEMENT = "panelElement";

	return {
		_create: function() {
			// Setup the panel element for future use
			this.set(PANEL_ELEMENT, this.element.find(".window"));
			// Make the widget element position absolute so that it can be moved around
			this.element.addClass("panel-top-level");
			// Make the close button hide the panel
			this.get(PANEL_ELEMENT).find(".close").click(function() { this.show(false); }.bind(this))
		},

		show: function(doShow) {
			doShow = (typeof doShow !== 'undefined') ? doShow : true;
			this.get(PANEL_ELEMENT).toggleClass("hidden", !doShow);
		}
	};
})()));