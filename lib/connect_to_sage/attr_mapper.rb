module ConnectToSage

  class AttrMapper
    attr_reader :obj
    
    def initialize(options = {}, &block)
      @options = options
      @map_proc = block
    end
    
    def match_for(obj)
      @obj = obj
      @map = Hash.new
      instance_eval &@map_proc unless @map_proc.nil?
      yield(self)
    end
    
    def match(attribute, *alternatives)
      result = if @map.has_key?(attribute)
        @map[attribute]
      else
        alternatives.unshift(attribute)
        alternatives.map! do |a| 
          a.is_a?(Symbol) ? "#{@options[:prefix]}#{a.to_s}#{@options[:suffix]}".to_sym : a
        end
        alternatives.reject! { |a| a.is_a?(Symbol) and !obj.respond_to?(a) }
        raise UnmappedAttribute.new(obj, attribute) if alternatives.empty?
        if alternatives.first.is_a?(Symbol)
          if /^to_.*_xml$/ =~ alternatives.first.to_s
            obj.__send__(alternatives.first, obj.sage_xml_builder)
          else
            obj.__send__(alternatives.first)
          end
        else
          alternatives.first
        end
      end
      
      if result.kind_of?(ActiveRecord::Base) and result.respond_to?("to_#{attribute.to_s}_xml")
        result.__send__("to_#{attribute.to_s}_xml", obj.sage_xml_builder)
      else
        begin
          result.xmlschema 
        rescue NoMethodError 
          result
        end
      end
    end
    
    private
    
      def method_missing(method, *args, &block)
        @map[method.to_sym] = case args.length
        when 0 then nil
        when 1 then args.first
        else args          
        end
      end

  end
  
  class UnmappedAttribute < StandardError
    def initialize(obj, attribute)
      super "No match for #{attribute} in #{obj.class.to_s}"
    end    
  end
  
end  

