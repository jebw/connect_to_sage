module ConnectToSage
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
  
    def sage_invoice(fieldmap = {})
      extend AttributeMapper
      @@sage_invoice_map = fieldmap
      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_invoice_xml" do |x|
        x.Invoice do
          
        end
      end
    end
    
    def sage_sales_order(fieldmap = {})
      extend AttributeMapper
      @@sage_sales_order_map = fieldmap
      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      map_attribute(@@sage_sales_order_map, 'Id')
      map_attribute(@@sage_sales_order_map, 'Forename') || raise(InvalidFormatError)
      map_attribute(@@sage_sales_order_map, 'Surname')
      map_attribute(@@sage_sales_order_map, 'RandomField') || raise(InvalidFormatError)
      
      define_method "to_sales_order_xml" do |x|
        x.SalesOrder do
          @@sage_sales_order_map.each do |k,v|
            if v.is_a?(Symbol)
              x.__send__ k, send(v)
            else
              x.__send__ k, v
            end
          end
        end
      end
    end
    
    def sage_customer(fieldmap = {})
      extend AttributeMapper
      @@sage_customer_map = fieldmap
      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_customer_xml" do |x|
        x.Customer do
          x.foobar
        end
      end
    end
  
  end
  
  module AttributeMapper
    def map_attribute(map, attribute, alternatives = [])
      return map[attribute] if map.has_key?(attribute)
      
      needles = [ attribute, attribute.underscore, attribute.downcase ]
      needles += alternatives
      
      needles.each do |needle|
        if self.methods.include?(needle)
          map[attribute] = needle.to_sym
          return needle.to_sym
        end
      end
      
      nil
    end
  end
  
  class InvalidFormatError < RuntimeError
  end
  
end
