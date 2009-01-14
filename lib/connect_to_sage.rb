module ConnectToSage
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
  
    def sage_invoice(attr_map = {})
      @@i_map = attr_map
      @@i_map_built = false
      
      include AttributeMapper      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_invoice_xml" do |xml|
        @@i_map_built || build_invoice_map
      
        xml.Invoice do
          write_sage_xml(@@i_map, xml)
        end
      end
      
      define_method "build_invoice_map" do
        map_attribute(@@i_map, 'Id')
      
        @@i_map_built = true
      end
    end
    
    def sage_sales_order(attr_map = {})
      @@so_map = attr_map
      @@so_map_built = false
      
      include AttributeMapper      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
            
      define_method "to_sales_order_xml" do |xml|
        @@so_map_built || build_sales_order_map
              
        xml.SalesOrder do
          to_sage_xml(@@so_map, xml)
        end
      end
      
      define_method "build_sales_order_map" do
        map_attribute(@@so_map, 'Id')
        map_attribute(@@so_map, 'Forename')
        map_attribute(@@so_map, 'Surname') || unmapped_attribute('Surname')
        map_attribute(@@so_map, 'RandomField')
        map_attribute(@@so_map, 'Desc')
        
        @@so_map_built = true
      end
      
    end
    
    def sage_customer(attr_map = {})
      @@c_map = attr_map
      @@c_map_built = false
      
      include AttributeMapper      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_customer_xml" do |xml|
        @@c_map_built || build_customer_map
      
        xml.Customer do
          to_sage_xml(@@c_map, xml)
        end
      end
      
      define_method "build_customer_map" do
        map_attribute(@@c_map, 'Id')
      
        @@c_map_built = true
      end
    end
  
  end
  
  module AttributeMapper
    
    def unmapped_attribute(attribute)
      raise UnmappedAttributeError, 
        "#{self.class.to_s} does not have a #{attribute} method, add one or add it to the attribute map"
    end
    
    def map_attribute(attr_map, attribute, alternatives = [])
      return true if attr_map.has_key?(attribute)
      
      needles = [ attribute, attribute.underscore, attribute.downcase ]
      needles += alternatives if alternatives
              
      result = needles.find { |needle| methods.include?(needle) }
      attr_map[attribute] = result.to_sym unless result.nil?
      
      attr_map.has_key?(attribute)
    end
    
    def to_sage_xml (attr_map, xml = nil)
      if xml.nil?
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
      end
    
      attr_map.each do |k,v|
        next if v.nil?
        
        if v.is_a?(Symbol)
          xml.__send__ k, __send__(v)
        else
          xml.__send__ k, v
        end
      end
    end
    
  end
  
  class UnmappedAttributeError < RuntimeError
  end
  
end
