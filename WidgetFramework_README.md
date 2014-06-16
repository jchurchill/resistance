The "JJ" widget framework V 1.0
===============================

********** Usage ************

In a rails app, create the following directories:

Widget Views: 			app/views/widgets
Widget Javascripts: 	app/assets/javascripts/widgets
Widget Stylesheets: 	app/assets/stylesheets/widgets

A file in each of these constitutes one "widget".
For example, you might have a widget called "Panel". The following three files will exist:

```
app/views/widgets/_panel.html.erb
app/assets/javascripts/widgets/panel.js
app/assets/stylesheets/widgets/panel.css[.less|.scss|...]
```



********** Using a widget on your page ************

You may not know how to set up a widget yet, but let's talk first about what it would even look like to use one.
Suppose I defined a widget called "panel" that I wanted to use in one of my application's pages.
Here's what the page's html.erb might look like:

```
<%= widget :panel, 'itemSelectorPanel', {
	title_text: "My Panel"
} %>
```

The function "widget" renders a widget on your page.

The symbol :panel indicates which widget to render.

The string 'itemSelectorPanel' provides the widget instance with a name.
When widgets are nested, the outer widget will be able to reference the inner widget instance in javascript by this identifier.
This name must be unique to either the page or the parent widget (depending on the context in which it is used).

Finally, the last argument is a hash that provides arbitrary data for use by
both the html.erb of the widget being rendered, as well as the instance of the widget in javascript.
This provides you with a way to parameterize your widgets.
In this Panel example, we might have the following snippet in our _panel.html.erb:

```
<div class="topBar">
	<%= title_text %>
	<span class='close'>&nbsp;</span>
</div>
```



********** Widget views ************

The widget view is a partial html file which represents the html contents of the widget.

As mentioned earlier, data that is passed to the widget may be used here.

It is interesting to note that widgets may contain other widgets.

Here's an example "test" widget that renders two "testsub" widgets as part of its html body.

```
<div style="border:1px solid black;padding:2px">
	<div>TEST WIDGET</div>
	<div>
		<div>Subwidget 1:</div>
		<%= widget 'testsub', 'testsub1', { testsub_string: test_string } %>
		<div>Subwidget 2:</div>
		<%= widget 'testsub', 'testsub2', { testsub_string: test_string } %>
	</div>
</div>
```




********** Widget javascripts ************

The widget javascript achieves three main things for a widget:

1. Provides a namespace for arbitrary functions related to the widget

2. Allows you to "initialize" a widget instance by setting up any events related to interacting with the widget

3. Defines the widget's public API that may be used by other referencing widgets.

A widget javascript should be thought of like a class definition in an object-oriented programming language.
It has "public" methods, "private" methods (those preceded by an underscore, by convention), and fields / properties.

The widget framework will automatically generate in javascript an instance of each widget used on the page being displayed.
When doing so, it will automatically initialize each instance to have

	a) The data the widget was created with in the call to <%= widget ... %>
	
	b) References to subwidgets that were created in the context of a parent widget

For (a), this data can be accessed within the context of a widget via this.get("my_property").

For (b), the reference to the subwidget can be accessed via this.subwidget("my_subwidget_name").

Widget javascripts are files with the following structure:

```
$.widget(
'jj.panel',
$.extend(JJ.WidgetBase, (function() {
	return {
		_create: function() {
			// initial setup here
		}

		// other functions for the widget here
	};
})()));
```

In general, 'jj.panel' would be replaced with 'jj.#{widget_name}'.
Note that erb may NOT be used in this file -- and it should not be necessary, since widget parameters are automatically populated in each widget instance.




********** Widget stylesheets ************

Widget stylesheets are not complicated at all. Simply put, these are files that will be sent to
the browser when there is at least one instance of the widget on the page.





********** Hooking it all together ************

Once you have created the three files required for a widget, you're almost there.
The last thing is to look at app/helpers/widget_master.rb.

The WIDGETS hash at the top of the file must list your widget and some basic properties about it.
From looking at one key-value pair in the hash, it is probably pretty straightforward how to fill it out for any arbitrary widget:

```
:test => {
	:view => 'widgets/test',
	:js => ['widgets/test'],
	:style => ['widgets/test'],
	:dependencies => [:testsub]
},
```

Symbols :view, :js, and :style are simply pointers to where within each of the views, javascripts, and stylesheets folders each piece of the widget can be found.
Note that a widget can have several javascript and / or css files, though it would be unconventional.

The last symbol, :dependencies, is a list of symbols of other widgets in the widget_master that this widget depends on.
That is, this widget directly uses the widgets listed in its dependencies.
To be clear, if Widget A uses a Widget B, and Widget B uses a Widget C, A need not list [B,C] as dependencies; only [B].





********** Some one-time initial setup notes ************

There are a few files that are essential to the widget framework:

app/javascripts/application.js
	In this, we include other js files necessary for the core widget framework.
	Notably, app/javascripts/widgets/jjwidget.js, and jqueryui.js (several files)

app/javascripts/widgets/jjwidget.js
	This contains a small amount of core JJWidget framework code that needs to run client-side before widgets can be created.

app/controllers/application_controller.rb
	A few lines were added to the top of this file to allow much of the widget framework to function.

app/helpers/widget_helper.rb
	The majority of widget framework methods and core code live here.

app/views/layouts/_widget.html.erb
	A layout used by all widgets which wraps each in a uniform container so that they can be referenced client-side.

app/views/widgets/_widget.html.erb
	A file that is included once, at the end of every page, that includes a script tag to set up all widget instances that are used by that page.

app/views/layouts/application.html.erb
	Several lines of code were added to this file to allow for inclusion of widget javascripts and stylesheets for any widgets used on the page.
