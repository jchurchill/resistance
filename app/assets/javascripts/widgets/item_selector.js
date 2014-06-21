//= require jquery.ui.autocomplete

$.widget(
'jj.item_selector',
$.extend(JJ.WidgetBase, (function() {
	var
	// Propeties auto-populated from model
	GET_ITEMS_URL = 'getItemsUrl',

	// Properties created internally
	AUTOCOMPLETE = "autocomplete";

	return {
		_create: function() {
			// Attach a jquery autocomplete to the selector's input el
			this.element.autocomplete({
				appendTo: 'input.item-selector',
				autoFocus: true,
				delay: 500,
				minLength: 0,
				source: this.get(GET_ITEMS_URL)
			});
			this.set(AUTOCOMPLETE, this.element.data("ui-autocomplete"));
		},

		// Autocomplete interface memebers exposed

		enable: function() {
			this.get(AUTOCOMPLETE).enable();
		},

		disable: function() {
			this.get(AUTOCOMPLETE).disable();
		},

		close: function() {
			this.get(AUTOCOMPLETE).close();
		},

		search: function(value) {
			this.get(AUTOCOMPLETE).search(value);
		}

		// Private members
	};
})()));