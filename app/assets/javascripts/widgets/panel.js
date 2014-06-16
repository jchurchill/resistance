$.widget(
'jj.panel',
$.extend(JJ.WidgetBase, (function() {
	var DUMMY = null;

	return {
		_create: function() {
			// Make the close button hide the panel
			this.element.find(".close").click(function() { this.show(false); }.bind(this))
		},

		show: function(doShow) {
			doShow = (typeof doShow !== 'undefined') ? doShow : true;
			this.element.find(".window").toggleClass("hidden", !doShow);
		}
	};
})()));