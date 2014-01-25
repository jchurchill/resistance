module WidgetHelper

	def initialize_widget_framework ()
		@widget_helper_widget_framework = WidgetFramework.new
		p '##### Widget framework initialized.'
	end

	def widget (widget_type, widget_instance_name, widget_data={})
		render_args = @widget_helper_widget_framework
			.widget(widget_type, widget_instance_name, widget_data)
		render render_args
	end

	def set_widget_context (context)
		@widget_helper_widget_framework
			.set_widget_context(context)
	end

	def all_required_widgets_js
		js = @widget_helper_widget_framework
			.dependency_ordered_required_widgets_get(:js)
		if not js.empty?
			javascript_include_tag *js
		else
			return
		end
	end

	def all_required_widgets_style
		style = @widget_helper_widget_framework
			.dependency_ordered_required_widgets_get(:style)
		if not style.empty?
			stylesheet_link_tag *style
		else
			return
		end
	end

	def dependency_ordered_widget_instances
		@widget_helper_widget_framework
			.dependency_ordered_widget_instances
	end

	def widget_instance_data_options_object (widget_instance_id, js_widget_instance_lookup)
		@widget_helper_widget_framework
			.widget_instance_data_options_object(widget_instance_id, js_widget_instance_lookup)
	end

	def widget_framework_complete
		@widget_helper_widget_framework
			.widget_framework_complete
	end


	# Represents an object that holds state about the widgets being used on a page.
	# One of these is maintained by the ApplicationController and is used in combination
	# with the applcation.html.erb layout to produce all the html, script includes, and css
	# includes for every widget on the page.
	class WidgetFramework
		WIDGET_NS = 'jj'
		WIDGET_CLASS_PREFIX = 'jj-widget'
		WIDGET_LAYOUT = 'layouts/widget'

		def initialize
			base_setup
		end

		################################################
		# METHODS THAT MAY ONLY BE CALLED PRE-COMPLETE #
		################################################

		def widget (widget_type, widget_instance_name, widget_data)
			if @completed_creating
				raise 'WidgetFramework: A widget may not be rendered after widget_framework_complete has been called.'
			end

			# Always use the symbol in case a string was passed in
			widget_type_sym = widget_type.to_sym

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

			# Register this instance of the widget under the widget type instances lookup.
			@widget_type_instances[widget_type_sym] ||= []
			@widget_type_instances[widget_type_sym].push(new_instance_uuid)

			# Get the static information about this widget type (e.g., the name of its partial view file)
			widget_info = WidgetMaster.get_widget_info(widget_type_sym)
			
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
					raise "WidgetFramework: The property #{key} is reserved by the widget framework and may not be used."
				}

			# Finally, return the arguments needed to render the widget requested inside the widget layout.
			return { partial: widget_info[:view], layout: WIDGET_LAYOUT, locals: widget_locals }
		end

		# Sets the current widget context to be the context provided.
		def set_widget_context (context)
			if @completed_creating
				raise 'WidgetFramework: The widget context may not be changed after widget_framework_complete has been called.'
			end
			@parent_widget_context = context
		end

		def widget_framework_complete
			if @completed_creating
				raise 'WidgetFramework: widget_framework_complete may not be called twice.'
			end
			if not @parent_widget_context.nil?
				raise 'WidgetFramework: The value of the widget context when the widget framework is completed rendering widgets should be nil (a top-level, non-widget page).'
			end
			@completed_creating = true
			@dependency_ordered_widget_types =
				WidgetMaster.get_ordered_dependencies(@widget_type_instances.keys)
			@dependency_ordered_widget_instances = 
				@dependency_ordered_widget_types.map { |w_type| 
					@widget_type_instances[w_type]
				}
				.flatten
				.map { |w_id|
					@widget_instance_properties[w_id]
				}
			return
		end


		#################################################
		# METHODS THAT MAY ONLY BE CALLED POST-COMPLETE #
		#################################################

		# Provides list of js or style files used by widgets on the page,
		# provided that it is called after all widgets have been rendered.
		# Arg "prop" should be one of [:js, :style].
		def dependency_ordered_required_widgets_get (prop)
			if not @completed_creating
				raise 'WidgetFramework: Aggregate operations on the widget framework are not allowed until widget_framework_complete has been called.'
			end
			prop_sym = prop.to_sym
			@dependency_ordered_widget_types.map { |w_type|
					WidgetMaster.get_widget_info(w_type)[prop_sym]
				}
				.flatten
				.compact
		end

		def dependency_ordered_widget_instances
			if not @completed_creating
				raise 'WidgetFramework: Aggregate operations on the widget framework are not allowed until widget_framework_complete has been called.'
			end
			return @dependency_ordered_widget_instances
		end

		def widget_instance_data_options_object (widget_instance_id, js_widget_instance_lookup)
			widget_data = @widget_instance_properties[widget_instance_id][:widget_data]

			widget_children =
				@widget_instances[widget_instance_id].inject({}) { | data_obj, child_wid |
					child = @widget_instance_properties[child_wid]
					w_kvp = {
						child[:widget_instance_name].to_s => JsonWidget.new(js_widget_instance_lookup, child_wid)
					}
					data_obj.merge!(w_kvp) { |key, oldval, newval| 
						raise "WidgetFramework: A widget may not contain two subwidgets with the same instance name: #{key}."
					}
				}

			all_data = widget_data.merge(widget_children) { |key, oldval, newval| 
				raise "WidgetFramework: A widget may not contain a subwidget with the same instance name as a widget property: #{key}."
			}
		end

		private
			def base_setup
				# A bool that indicates whether or not any more widgets may be created while rendering.
				# This exists for performance reasons; once we know that all widgets that ever will be
				# created have been created, we can do some post processing to make it so that rendering
				# the javascripts and widget instances in dependency order is a faster operation.
				@completed_creating = false

				# widget_instances
				# A mapping from the id of each created widget instance to the ids of its dependent widgets.
				# Example: {
				#		'a03bf0-23923' => ['39bfe932-becd91', '3bc94382-ff9485'],
				# 	'191fbe-1a80e' => []
				# }
				@widget_instances ||= {}

				# widget_instance_properties
				# A mapping from the id of each created widget instance to some important information about it.
				# Example:
				# {
				# 	'a03bf0-23923' => {
				# 		:widget_uuid => 					'a03bf0-23923',
				# 		:widget_type => 					:item_selector,
				# 		:widget_data_name => 			'jjItem_selector',
				# 		:widget_instance_name => 	'itemSelector1',
				# 		:widget_box_class => 			'jj-widget-a03bf0-23923',
				# 		:widget_data => 					{ page_size: 100 }
				# 	}
				# }
				@widget_instance_properties ||= {}

				# widget_type_instances
				# A mapping from each widget type being rendered in the view to the widget instance
				# ids of that type. Note that the keys of this hash represent all widget types that 
				# will exist on the page.
				# Example:
				# {
				# 	:item_selector => ['a03bf0-23923', '191fbe-1a80e'],
				# 	:other_widget  => ['39bfe932-becd91']
				# }
				@widget_type_instances ||= {}
			end

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
						:widget_uuid => new_instance_uuid,
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
				parent_widget_info = WidgetMaster.get_widget_info(parent_widget_type)
				# Ensure that the parent widget listed this widget as a dependency. If it did not, raise.
				if not parent_widget_info[:dependencies].include? this_widget_type
					raise "Widget '#{parent_widget_type}' contained an instance of widget '#{this_widget_type}', but was not listed as a dependency of '#{parent_widget_type}' in the WidgetMaster."
				end
			end

			# Used to override the way that a json widget is encoded so that it doesn't
			# get wrapped in quotes as a string, but rather is treated as a variable in js code.
			class JsonWidget < String
				def initialize(js_widget_instance_lookup, widget_id)
					@json_val = "#{js_widget_instance_lookup}['#{widget_id}']"
				end
				def encode_json(encoder)
					return @json_val
				end
			end
	end
end