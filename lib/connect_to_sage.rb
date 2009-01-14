module ConnectToSage
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
  
    def sage_invoice(fieldmap = {})
      @@sage_invoice_map = AttributeMapper.new(self, fieldmap)
      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_invoice_xml" do |x|
        x.Invoice do
          @@sage_invoice_map.write_xml(x, self)
        end
      end
    end
    
    def sage_sales_order(fieldmap = {})
      @@so_map = fieldmap
      @@so_map_built = false
      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
            
      define_method "to_sales_order_xml" do |x|
        @@so_map_built || build_sales_order_map
              
        x.SalesOrder do
          #@@sage_sales_order_map.write_xml(x, self)
          
          @@so_map.each do |k, v|
            next if v.nil?
            
            if v.is_a?(Symbol)
              x.__send__ k, __send__(v)
            else
              x.__send__ k, v
            end
          end
        end
      end
      
      define_method "build_sales_order_map" do
        map_attribute(@@so_map, 'Id', [])
        map_attribute(@@so_map, 'Forename', [])
        map_attribute(@@so_map, 'Surname', [])
        map_attribute(@@so_map, 'RandomField', [])
        map_attribute(@@so_map, 'Desc', [])
        
        @@so_map_built = true
      end
      
      define_method "map_attribute" do |attr_map, attribute, alternatives|
        return true if attr_map.has_key?(attribute)
        
        needles = [ attribute, attribute.underscore, attribute.downcase ]
        needles += alternatives if alternatives
                
        result = needles.find { |needle| methods.include?(needle) }
        attr_map[attribute] = result.to_sym unless result.nil?
        
        attr_map.has_key?(attribute)
      end
    end
    
    def sage_customer(fieldmap = {})
      return
      @@sage_customer_map = AttributeMapper.new(self, fieldmap)
      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_customer_xml" do |x|
        x.Customer do
          @@sage_customer_map.write_xml(x, self)
        end
      end
    end
  
  end
  
  
  
  class InvalidFormatError < RuntimeError
  end
  
end
