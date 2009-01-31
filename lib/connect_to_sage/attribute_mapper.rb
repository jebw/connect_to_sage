module ConnectToSage

  module AttributeMapper
    
    def attribute_map(attr_map, alternatives)
      attribute = alternatives.first
      if attr_map.has_key?(attribute)
        return process_attribute(attribute, attr_map[attribute])
      end
      extend Customers
      alternatives.map! { |a| a.is_a?(Symbol) ? "#{attr_map[:prefix]}#{a.to_s}#{attr_map[:suffix]}".to_sym : a}
      
      valid_alternatives = alternatives.reject { |a| a.is_a?(Symbol) and not has_method?(a) }
      if valid_alternatives.empty?
        __send__(alternatives.first)
      else
        process_attribute(attribute, valid_alternatives.first)
      end
    end
    
    def process_attribute(attribute, target)
      result = if target.is_a?(Symbol)
        (/^to_.*_xml$/ =~ target.to_s ? __send__(target, @sage_xml_builder) : __send__(target))
      elsif target.is_a?(Proc)
        target.call(self)
      else
        target
      end
      
      if result.kind_of?(ActiveRecord::Base) and result.methods.include?("to_#{attribute.to_s}_xml")
        result.__send__("to_#{attribute.to_s}_xml", @sage_xml_builder)
      else
        result.methods.include?('xmlschema') ? result.xmlschema : result
      end
    end
    
    def has_method?(method_name)
      methods.include?(method_name.to_s)
    end
    
  end

end
