$.widget(
'jj.testsub',
$.extend(JJ.WidgetBase, (function() {
	// Some constants
	var SOME_CONST = 100,
		other_stuff = {},
		MY_STRING = 'testsub_string';

	// The actual widget prototype with methods to use it by
	return {
		_create: function() {
			console.log('you created a sub widget!');
		},

		doAlert: function() {
			alert('My Substring is ' + this.options[MY_STRING]);
		}
	};
})()));