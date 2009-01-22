module ConnectToSage
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
  
    def sage_invoice(attr_map = {})
      @@invoice_map = attr_map
      
      include AttributeMapper      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_invoice_xml" do |xml|
        @sage_xml_builder ||= xml
        xml.Invoice do
          xml.Id invoice_map(:id)
          xml.CustomerId invoice_map(:customer_id)
          xml.InvoiceNumber invoice_map(:invoice_number) rescue NoMethodError
          xml.CustomerOrderNumber invoice_map(:customer_order_number) rescue NoMethodError
          xml.AccountReference invoice_map(:account_reference) rescue NoMethodError
          xml.OrderNumber invoice_map(:order_number, :id)# rescue NoMethodError
          xml.ForeignRate invoice_map(:foreign_rate) rescue NoMethodError
          xml.Currency invoice_map(:currency) rescue NoMethodError
          xml.Notes1 invoice_map(:notes1) rescue NoMethodError
          xml.CurrencyUsed invoice_map(:currency_used) rescue NoMethodError
          xml.InvoiceDate invoice_map(:invoice_date, :created_at) rescue NoMethodError
          xml.InvoiceType invoice_map(:invoice_type) rescue NoMethodError
          xml.InvoiceAddress do
            invoice_map(:invoice_address)
          end
          xml.InvoiceDeliveryAddress do
            invoice_map(:invoice_delivery_address, :to_invoice_delivery_address_xml) rescue NoMethodError
          end
          xml.Courier invoice_map(:courier) rescue NoMethodError
          xml.SettlementDays invoice_map(:settlement_days) rescue NoMethodError
          xml.SettlementDiscount invoice_map(:settlement_discount) rescue NoMethodError
          xml.GlobalTaxCode invoice_map(:global_tax_code) rescue NoMethodError
          xml.GlobalDepartment invoice_map(:global_department) rescue NoMethodError
          xml.PaymentAmount invoice_map(:payment_amount) rescue NoMethodError
        end
      end
      
      define_method "invoice_map" do |*alternatives|
        attribute_map(@@invoice_map, alternatives)
      end
      
    end
    
    def sage_invoice_address(attr_map = {})
      @@invoice_address_map = attr_map
      include AttributeMapper
      
      define_method "to_invoice_address_xml" do |xml|
        @sage_xml_builder ||= xml
        xml.InvoiceAddress "This is an Address"
      end
      
      define_method "invoice_address_map" do |*alternatives|
        attribute_map(@@invoice_address_map, alternatives)
      end
    end
    
    def sage_invoice_delivery_address(attr_map = {})
      @@invoice_delivery_address_map = attr_map
      include AttributeMapper
      
      define_method "to_invoice_delivery_address_xml" do |xml|
        @sage_xml_builder ||= xml
        xml.Foo 'bar'
      end
      
      define_method "invoice_delivery_address_map" do |*alternatives|
        attribute_map(@@invoice_delivery_address_map, alternatives)
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
    
    def attribute_map(attr_map, alternatives)
      attribute = alternatives.first
      if attr_map.has_key?(attribute)
        return process_attribute(attr_map[attribute])
      end
      
      alternatives.reject! { |a| a.is_a?(Symbol) and not has_method?(a) }
      if alternatives.empty?
        __send__(attribute)
      else
        process_attribute(alternatives.first)
      end
    end
    
    def process_attribute(attribute)
      result = if attribute.is_a?(Symbol)
        r = (/^to_.*_xml$/ =~ attribute.to_s ? __send__(attribute, @sage_xml_builder) : __send__(attribute))
        if r.kind_of?(ActiveRecord::Base) and r.methods.include?("to_#{attribute.to_s}_xml")
          r.__send__("to_#{attribute.to_s}_xml", @sage_xml_builder)
        else
          r
        end
      elsif attribute.is_a?(Proc)
        attribute.call
      else
        attribute
      end
      
      result.methods.include?('xmlschema') ? result.xmlschema : result
    end
    
    def has_method?(method_name)
      methods.include?(method_name.to_s)
    end
    
  end
  
  class UnmappedAttributeError < RuntimeError
  end
  
end
