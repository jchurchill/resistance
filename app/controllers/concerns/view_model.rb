class ViewModel
    # any instance variable on this class
    # will be serialized to json and sent with
    # the widget.
    
    def to_json
        properties = self.instance_variables
        property_hash = Hash.new
        for prop in properties
            # strip the leading "@"
            prop_name = prop[1..-1]
            property_hash[prop_name] = self.instance_variable_get(prop).to_json
        end
        return property_hash
    end
end

class JJWidgetBuilder
    attr_accessor :model
end