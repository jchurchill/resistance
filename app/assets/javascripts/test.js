$.widget(
'jj.test',
// jQuery.Widget, // this is default
(function() {
	// Some constants
	var SOME_CONST = 100,
		other_stuff = {};

	// The actual widget prototype with methods to use it by
	return {
		_create: function() {
			console.log("test widget created!");
		}
	};
})());