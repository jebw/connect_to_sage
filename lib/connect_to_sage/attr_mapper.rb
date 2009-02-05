module ConnectToSage

  class AttrMapper
    attr_reader :obj
    
    def initialize(&block)
      @map_proc = block
    end
    
    def match_for(obj)
      @obj = obj
      @map = Hash.new
      instance_eval &@map_proc
      yield(self)
    end
    
    def match(attribute, *alternatives)
      if @map.has_key?(attribute)
        @map[attribute]
      elsif obj.respond_to?(attribute)
        obj.__send__(attribute)
      else
        alternatives.reject! { |a| a.is_a?(Symbol) and !obj.respond_to?(a) }
        raise UnmappedAttribute.new(obj, attribute) if alternatives.empty?
        if alternatives.first.is_a?(Symbol)
          obj.__send(alternatives.first)
        else
          alternatives.first
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

