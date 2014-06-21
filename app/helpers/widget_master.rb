module WidgetMaster
	WIDGETS = {
		:test => {
			:view => 'widgets/test',
			:js => ['widgets/test'],
			:style => ['widgets/test'],
			:dependencies => [:testsub]
		},
		:testsub => {
			:view => 'widgets/testsub',
			:js => ['widgets/testsub'],
			:style => [],
			:dependencies => []
		},
		:item_selector => {
			:view => 'widgets/item_selector',
			:js => ['widgets/item_selector'],
			:style => [],
			:dependencies => []
		},
		:panel => {
			:view => 'widgets/panel',
			:js => ['widgets/panel'],
			:style => ['widgets/panel'],
			:dependencies => []
		}
	}

	def self.get_widget_info (widget_type)
		widget_type_sym = widget_type.to_sym
		if not WIDGETS.has_key? widget_type_sym
			raise "Widget type '#{widget_type_sym}' could not be found in the WidgetMaster."
		end
		return WIDGETS[widget_type_sym]
	end

	# Given a list of widgets A, B, C, ..., returns them and
	# all their dependencies ordered in dependency order. That is,
	# it is guaranteed that if X depends on Y, that Y is ordered before X.
	def self.get_ordered_dependencies (widget_types)
		order_hash = {}
		widget_types.each { |wt|
			if not WIDGETS.has_key? wt
				raise "Widget type '#{wt}' could not be found in the WidgetMaster."
			end
			ordered_dependencies_internal!(wt, 0, order_hash)
		}
		return order_hash.sort { |kvp1,kvp2| kvp2[1] <=> kvp1[1] }.map { |kvp| kvp[0] }
	end

	private
		def self.ordered_dependencies_internal! (widget_type, depth, order_hash)
			order_hash[widget_type] = depth if depth > (order_hash[widget_type] || -1)
			deps = WIDGETS[widget_type][:dependencies] || []
			deps.each { |d| ordered_dependencies_internal!(d, depth + 1, order_hash) }
			return
		end

		# 1. Check that dependencies of each widget exist in the master widget list.
		# 	If violation found, throw an exception.
		# 2. Check for circular dependencies.
		# 	If a circular dependency is found, throw an exception.
		def self.verify_all_widget_dependencies
			WIDGETS.each { |widget,props|
				deps = props[:dependencies] || []
				deps.each { |d| 
					raise "Widget '#{widget}' has invalid dependency '#{d}'" if not WIDGETS.has_key? d
				}
			}
			circ_dep_widgets = WIDGETS.keys.select { |widget| is_in_circular_dependency widget }
			if not circ_dep_widgets.empty?
				widget_list = circ_dep_widgets.join(', ')
				raise "The following widget(s) are involved in circular dependencies: #{widget_list}"
			end
		end

		def self.is_in_circular_dependency (widget_type)
			all_deps = get_expanded_dependencies(widget_type)
			return all_deps.include? widget_type
		end

		def self.get_expanded_dependencies (widget_type)
			all_deps = Set.new
			expand_dependencies! widget_type, all_deps
			return all_deps
		end

		def self.expand_dependencies! (widget_type, expanded_deps)
			deps = WIDGETS[widget_type][:dependencies] || []
			deps.each { |d| 
				if not expanded_deps.include? d
					expanded_deps << d
					expand_dependencies!(d, expanded_deps)
				end
			}
		end
	
	# This runs once on App Start when this class is defined.
	if Rails.env.development?
		verify_all_widget_dependencies
	end
end