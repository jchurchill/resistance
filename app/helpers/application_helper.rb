module ApplicationHelper
	WIDGET_NS = 'jj'
	WIDGET_CLASS_PREFIX = 'jj-widget'
	WIDGET_LAYOUT = 'layouts/widget'

	def widget (widget_type, widget_instance_name, widget_data={})
		# TODO JC: figure out way to remove these from this function
		@widget_instances = @widget_instances || {}
		@widget_instance_properties = @widget_instance_properties || {}
		@registered_widget_types = @registered_widget_types || Set.new

		# Always use the symbol in case a string was passed in
		widget_type_sym = widget_type.to_sym

		# Register this widget as being "used" on this page so that we later
		# know to include its javascript on the page too.
		@registered_widget_types.add(widget_type_sym)

		# Save the parent widget context for this widget instance
		parent_context = @parent_widget_context

		# Dev only: check that the widget being rendered is actually listed as a dependency
		# of the parent widget, if we are rendering within a parent widget.
		if Rails.env.development?
			enforce_widget_dependencies(parent_context, widget_type_sym)
		end

		# Create a new instance of a widget of type widget_type, instance name widget_instance_name,
		# and register its existence under the current parent widget context (if one exists)
		new_instance_uuid = create_new_widget_instance(
			widget_type_sym, widget_instance_name, parent_context, widget_data)

		# Get the static information about this widget type (e.g., the name of its partial view file)
		widget_info = WidgetMaster::get_widget_info(widget_type_sym)
		
		# Set the new parent context to be this widget, so that this will be the parent context for
		# subwidgets of this widget when they are rendered.
		set_widget_context(new_instance_uuid)

		# Generate information about this widget that will be used by the widget template.
		widget_template_info =
			get_widget_template_info(widget_type_sym, new_instance_uuid, parent_context)

		# Get the local variables that will be passed to the widget partial by merging
		# the property :widget_template_info with all data properties of the widget instance.
		# If there is a conflict between keys, raise an exception.
		widget_locals = {
				:widget_template_info => widget_template_info
			}
			.merge!(widget_data) { |key, oldval, newval| 
				raise "The property #{key} is reserved by the widget framework and may not be used."
			}

		# Finally, render the widget requested inside the widget layout.
		render partial: widget_info[:view], layout: WIDGET_LAYOUT, locals: widget_locals
	end

	# Sets the current widget context to be the context provided.
	def set_widget_context (context)
		@parent_widget_context = context
	end

	# Renders script tags for all javascript files used by widgets on the page,
	# provided that it is called after all widgets have been rendered.
	def all_required_widgets_js
		js = all_required_widgets(:js)
		if not js.empty?
			javascript_include_tag *js
		else
			return
		end
	end

	# Renders style links for all stylesheet files used by widgets on the page,
	# provided that it is called after all widgets have been rendered.
	def all_required_widgets_style
		style = all_required_widgets(:style)
		if not style.empty?
			stylesheet_link_tag *style
		else
			return
		end
	end

	def all_widget_instances
		return @widget_instance_properties
	end

	def widget_instance_children (widget_instance_id)
		# TODO: add check for naming collision between widgets and widget data here!
		children = @widget_instances[widget_instance_id].map { | child_wid |
			child = @widget_instance_properties[child_wid]
			{
				:instance_name => child[:widget_instance_name],
				:instance_id => child_wid
			}
		}
		return children
	end

	private
		# Returns all information passed to the widget partial specifically for the
		# widget layout template rendering.
		def get_widget_template_info (widget_type, widget_uuid, parent_widget_context)
			return {
				:widget_type => widget_type,
				:widget_uuid => widget_uuid,
				:widget_class => "#{WIDGET_CLASS_PREFIX}-#{widget_uuid}",
				:widget_full_name => "#{WIDGET_NS}.#{widget_type}",
				:parent_widget_context => parent_widget_context
			}
		end

		# For all widgets required on the page, get some property about each
		# and return a list containing each value
		# Useful for getting every widget's js or css files, for example.
		def all_required_widgets (prop)
			prop_sym = prop.to_sym
			WidgetMaster::get_ordered_dependencies(@registered_widget_types)
				.map { |w_type|
					WidgetMaster.get_widget_info(w_type)[prop_sym]
				}
				.flatten
				.compact
		end

		# Create a new instance of a widget of type widget_type, instance name widget_instance_name,
		# and register its existence under the current parent widget context (if one exists)
		def create_new_widget_instance (widget_type, widget_instance_name, parent_widget_context, widget_data)
			# Generate a uuid for the instance of the widget being rendered
			new_instance_uuid = SecureRandom.uuid

			# If we're inside a parent widget's context (context is not nil),
			# then record that this widget instance is contained within the parent
			# widget instance.
			if not parent_widget_context.nil?
				@widget_instances[parent_widget_context].push(new_instance_uuid)
			end

			# Map this instance to a list of the instance of other widgets that it contains
			# This list will be populated as this widget instance is rendered.
			@widget_instances[new_instance_uuid] = []

			# For this widget instance, save information about its widget type and instance name
			# for later (needed when setting up its instance in javascript).
			@widget_instance_properties[new_instance_uuid] = {
					:widget_type => widget_type,
					:widget_data_name => (WIDGET_NS + widget_type.to_s.capitalize),
					:widget_instance_name => widget_instance_name,
					:widget_box_class => "#{WIDGET_CLASS_PREFIX}-#{new_instance_uuid}",
					:widget_data => widget_data
				}

			return new_instance_uuid
		end

		# Given a parent widget instance context and the type of the widget currenly
		# being rendered, check with the widget master that this widget is in fact
		# registered as a dependency of the parent widget. This check exists purely
		# to prevent developer mistakes and should not be run in production.
		def enforce_widget_dependencies (parent_widget_context, this_widget_type)
			# If not within a parent widget context, no dependencies to enforce.
			if parent_widget_context.nil?
				return
			end
			# Get the static information about this widget's parent widget type
			parent_widget_type = @widget_instance_properties[parent_widget_context][:widget_type]
			parent_widget_info = WidgetMaster::get_widget_info(parent_widget_type)
			# Ensure that the parent widget listed this widget as a dependency. If it did not, raise.
			if not parent_widget_info[:dependencies].include? this_widget_type
				raise "Widget '#{parent_widget_type}' contained an instance of widget '#{this_widget_type}', but was not listed as a dependency of '#{parent_widget_type}' in the WidgetMaster."
			end
		end
end
