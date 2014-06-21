class ItemSelectorViewModel < ViewModel
  attr_accessor :empty_text
end

class ItemSelectorBuilder < JJWidgetBuilder
	def initialize (view_model=nil)
		@model = view_model || ItemSelectorViewModel.new
		@model.empty_text = "Select an item"
	end

	def empty_text (text)
		@model.empty_text = text
	end
end