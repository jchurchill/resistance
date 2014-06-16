$.widget(
'jj.test',
$.extend(JJ.WidgetBase, (function() {
	// Some constants
	var SOME_CONST = 100,
		other_stuff = {},
		SUBWIDGET_1 = 'testsub1',
		SUBWIDGET_2 = 'testsub2';

	// The actual widget prototype with methods to use it by
	return {
		_create: function() {
			console.log("test widget created!");
			this.subwidget(SUBWIDGET_1).doAlert();
			this.subwidget(SUBWIDGET_2).doAlert();
		}
	};
})()));