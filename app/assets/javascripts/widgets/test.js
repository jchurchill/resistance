$.widget(
'jj.test',
// jQuery.Widget, // this is default
(function() {
	// Some constants
	var SOME_CONST = 100,
		other_stuff = {},
		SUBWIDGET_1 = 'testsub1',
		SUBWIDGET_2 = 'testsub2';

	// The actual widget prototype with methods to use it by
	return {
		_create: function() {
			console.log("test widget created!");
			this.options[SUBWIDGET_1].doAlert();
		}
	};
})());