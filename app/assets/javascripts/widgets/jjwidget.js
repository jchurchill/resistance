window.JJ = {};
window.JJ.Widget = {
	// TODO: don't hardcode reference to "jj" namespace
	namespace: "jj",

	/* Mapping of widget uuid => jquery widget instance,
	 * for all widgets used on the page
	 */
	instances: {},

	/* Registers a widget with the client-side widget framework.
	 */
	createWidget: function (
		id,			// Universal identifier for the widget
		boxclass,	// Unique class of the content box of this widget
		type,		// Name for the type of this widget
		properties	// { data: [obj], subwidgets: [obj] }
	) {
		var widgetContentBox = $("." + boxclass),
			widgetData = { data: properties.data, subwidgets: {} },
			// TODO: don't hardcode reference to "jj" namespace
			widgetTypeExists = $[this.namespace].hasOwnProperty(type),
			widget;

		// Sanity check that this widget type exists
		if (!widgetTypeExists) { throw "Widget type " + type + " not loaded."; }

		// properties.subwidgets is an object mapping property names to ids;
		// convert this into a mapping of property names to widget instances
		// so that the widget instance we are creating here can be loaded
		// with references to its subwidget instances. Note that since widgets are
		// created in dependency order, the subwidget instances are guaranteed to already exist.
		$.each(properties.subwidgets, (function (propertyName, widgetInstanceId) {
			widgetData.subwidgets[propertyName] = this.instances[widgetInstanceId];
		}).bind(this));

		// Create the widget.
		// In jquery's widget framework, declaring $.widget(...) (see any widget js file)
		// creates a property on every jquery object with the name of the widget.
		// This property is a function that does the following:
		// 	-   Creates a widget of that type and adds it to the "data" 
		// 		property of the content box
		// 	-   Initializes the widget instance with the widgetData provided.
		// 		These can be accessed internally in the widget in "this.options".
		// 		Note that in this object we're defining only "data" and "subwidgets".
		widgetContentBox[type](widgetData);

		// To get the actual instance of the widget that was created, we use jquery's
		// "data" function for jquery objects where the widget instance is stored.
		// It is stored in a property with name {widget_namespace}-{widget_name},
		// also known as the "widgetFullName" to widget instances.
		widget = widgetContentBox.data(this._widgetFullName(type));

		// Register this widget with the widget framework so that
		// other widgets may reference it by its ID.
		this.instances[id] = widget;
	},

	// TODO: don't assume this structure - figure out how we can use the
	// TODO: definition of the widget to get at its widgetFullName
	_widgetFullName: function(widgetType) {
		return this.namespace + "-" + widgetType;
	}
};

/* All widgets should extend this to get some basic methods
 * that are generally convenient and abstract away some of the details
 * of the widget framework.
 */
window.JJ.WidgetBase = $.extend($.Widget, {
	get: function(propName) {
		return this.options.data[propName];	
	},
	set: function(propName, val) {
		return this.options.data[propName] = val;	
	},
	subwidget: function(propName) {
		return this.options.subwidgets[propName];
	}
});