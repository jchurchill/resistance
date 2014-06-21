module WidgetHelper

	def widget_framework_initialize
		@widget_helper_widget_framework = WidgetFramework.new
		p '##### Widget framework initialized #####'
	end

	def widget_framework
		@widget_helper_widget_framework
	end

	def widget (widget_type, widget_instance_name, view_model=nil)
		return @widget_helper_widget_framework
			.widget(widget_type, widget_instance_name, view_model) do |render_args|
				render render_args
			end
	end

	class WidgetBuilderRenderer
		WIDGET_LAYOUT = 'layouts/widget'

		# Creates a WidgetBuilderRenderer, an object whose responsibility it is to provide
		# builder methods within a view that calls "widget", and finally to render it as html
		# view_partial:
		# 		the name of the partial html for the widget
		# template_info:
		# 		information needed by the widget_layout of the widget framework
		# builder_class_name: 
		# 		the name of the builder class for the widget (from WidgetMaster)
		# view_model:
		# 		the view_model parameter passed into the public widget method, can be nil
		# &render_callback:
		# 		a block that will be run once when the widget's view model is finalized, just before it is rendered
		# 		passed to the block will be two arguments:
		# 			1. the finalized view model
		# 			2. the args {:partial, :layout, :locals} that should be passed to an erb partial render
		def initialize (view_partial, template_info, builder_class_name, view_model, &render_callback)
			@view_partial = view_partial
			@template_info = template_info
			@render_callback = render_callback
			@builder = get_widget_builder(builder_class_name, view_model)
		end

		def render
			view_model = @builder.model
			widget_locals = {
				:widget_template_info => @template_info,
				:model => view_model
			}
			render_args = {
				:partial => @view_partial,
				:layout => WIDGET_LAYOUT,
				:locals => widget_locals
			}

			@render_callback.call(view_model, render_args) if not @render_callback.nil?
		end

		# all methods on this object otherwise go straight to the builder
		def method_missing (method_sym, *args, &block)
			if @builder.respond_to?(method_sym)
				@builder.send(method_sym, *args, &block)
				return self
			else
				super
			end
		end

		def respond_to?(method, include_private = false)
			super || @builder.respond_to?(method, include_private)
		end

		private
			def get_widget_builder (builder_class_name, view_model)
				builder_class = Object.const_get(builder_class_name)
				raise "Widget builder #{builder_class} is not a JJWidgetBuilder." if not builder_class < JJWidgetBuilder
				return builder_class.new(view_model)
			end
	end

	# Represents an object that holds state about the widgets being used on a page.
	# One of these is maintained by the ApplicationController and is used in combination
	# with the applcation.html.erb layout to produce all the html, script includes, and css
	# includes for every widget on the page.
	class WidgetFramework
		WIDGET_NS = 'jj'
		WIDGET_CLASS = 'jj-widget'

		def initialize
			base_setup
		end

		################################################
		# METHODS THAT MAY ONLY BE CALLED PRE-COMPLETE #
		################################################

		def widget (widget_type, widget_instance_name, view_model, &render_callback)
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

			# Get the static information about this widget type (e.g., the name of its partial view file)
			widget_info = WidgetMaster.get_widget_info(widget_type_sym)

			# Create a new instance of a widget of type widget_type, instance name widget_instance_name,
			# and register its existence under the current parent widget context (if one exists)
			new_instance_uuid = create_new_widget_instance(
				widget_type_sym, widget_instance_name, parent_context)

			# Register this instance of the widget under the widget type instances lookup.
			@widget_type_instances[widget_type_sym] ||= []
			@widget_type_instances[widget_type_sym].push(new_instance_uuid)
			
			# Set the new parent context to be this widget, so that this will be the parent context for
			# subwidgets of this widget when they are rendered.
			set_widget_context(new_instance_uuid)

			# Generate information about this widget that will be used by the widget template.
			widget_template_info = 
				get_widget_template_info(widget_type_sym, new_instance_uuid, parent_context)

			# Finally, return the widget as a BuilderRenderer which can be built further (with the specified widget builder), and finally rendered in the view
			return WidgetBuilderRenderer.new(widget_info[:view], widget_template_info, widget_info[:builder], view_model) do |finalized_view_model, render_args|
				set_widget_instance_view_model(new_instance_uuid, finalized_view_model)
				render_callback.call(render_args)
			end
		end

		# Sets the current widget context to be the context provided.
		def set_widget_context (context)
			if @completed_creating
				raise 'WidgetFramework: The widget context may not be changed after widget_framework_complete has been called.'
			end
			@parent_widget_context = context
		end

		def finish_widgets
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

		def all_required_widgets_js (view_renderer)
			js = dependency_ordered_required_widgets_get(:js)
			if not js.empty?
				view_renderer.javascript_include_tag *js
			else
				return
			end
		end

		def all_required_widgets_style (view_renderer)
			style = dependency_ordered_required_widgets_get(:style)
			if not style.empty?
				view_renderer.stylesheet_link_tag *style
			else
				return
			end
		end

		def dependency_ordered_widget_instances
			if not @completed_creating
				raise 'WidgetFramework: Aggregate operations on the widget framework are not allowed until widget_framework_complete has been called.'
			end
			return @dependency_ordered_widget_instances
		end

		def widget_instance_data_options_object (widget_instance_id)
			# The view model implements to_json
			widget_view_model = @widget_instance_properties[widget_instance_id][:widget_view_model]

			widget_children =
				@widget_instances[widget_instance_id].inject({}) { | data_obj, child_wid |
					child = @widget_instance_properties[child_wid]
					w_kvp = {
						child[:widget_instance_name].to_s => child_wid.to_s
					}
					data_obj.merge!(w_kvp) { |key, oldval, newval| 
						raise "WidgetFramework: A widget may not contain two subwidgets with the same instance name: #{key}."
					}
				}

			return { 'data' => widget_view_model, 'subwidgets' => widget_children }
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
				# 		:widget_view_model => 		(An object of type ViewModel, whose instance variables will be widget data)
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
					:widget_id => widget_content_box_id(widget_uuid),
					:parent_widget_context => parent_widget_context
				}
			end

			# Create a new instance of a widget of type widget_type, instance name widget_instance_name,
			# and register its existence under the current parent widget context (if one exists)
			def create_new_widget_instance (widget_type, widget_instance_name, parent_widget_context)
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
						:widget_id => widget_content_box_id(new_instance_uuid),
						:widget_instance_name => widget_instance_name
					}

				return new_instance_uuid
			end

			def set_widget_instance_view_model (widget_uuid, view_model)
				raise "No widget instance with uuid #{widget_uuid} created." if not @widget_instance_properties.has_key?(widget_uuid)
				@widget_instance_properties[widget_uuid][:widget_view_model] = (view_model || Hash.new)
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

			def widget_content_box_id (widget_uuid)
				"#{WIDGET_CLASS}-#{widget_uuid}"
			end
	end
end