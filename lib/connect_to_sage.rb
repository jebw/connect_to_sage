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
        xml.AddressLine1 invoice_address_map(:address_line_1)
        xml.AddressLine2 invoice_address_map(:address_line_2)
        xml.Town invoice_address_map(:town)
        xml.County invoice_address_map(:county)
        xml.Postcode invoice_address_map(:postcode)
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
        xml.AddressLine1 invoice_delivery_address_map(:address_line_1)
        xml.AddressLine2 invoice_delivery_address_map(:address_line_2)
        xml.Town invoice_delivery_address_map(:town)
        xml.County invoice_delivery_address_map(:county)
        xml.Postcode invoice_delivery_address_map(:postcode)
      end
      
      define_method "invoice_delivery_address_map" do |*alternatives|
        attribute_map(@@invoice_delivery_address_map, alternatives)
      end
    end
    
    def sage_sales_order(attr_map = {})
      @@sales_order_map = attr_map
      include AttributeMapper
      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
            
      define_method "to_sales_order_xml" do |xml|
        @@sales_order_map ||= xml
              
        xml.SalesOrder do
          xml.Id sales_order_map(:id)
          xml.Forename sales_order_map(:forename)
          xml.Surname sales_order_map(:surname)
          xml.RandomField sales_order_map(:random_field) rescue NoMethodError
          xml.Desc sales_order_map(:desc)
        end
      end
      
      define_method "sales_order_map" do |*alternatives|
        attribute_map(@@sales_order_map, alternatives)
      end
      
    end
    
    def sage_customer(attr_map = {})
      @@customer_map = attr_map      
      include AttributeMapper
      
      define_method "to_customer_xml" do |xml|
        @sage_xml_builder ||= xml
      
        xml.Customer do
          xml.Id customer_map(:id)
          xml.Name customer_map(:name)
        end
      end
      
      define_method "customer_map" do |*alternatives|
        attribute_map(@@customer_map, alternatives)
      end
    end
  
  end
  
  module AttributeMapper
    
    def attribute_map(attr_map, alternatives)
      attribute = alternatives.first
      if attr_map.has_key?(attribute)
        return process_attribute(attribute, attr_map[attribute])
      end
      
      alternatives.map! { |a| a.is_a?(Symbol) ? "#{attr_map[:prefix]}#{a.to_s}#{attr_map[:suffix]}".to_sym : a}
      
      alternatives.reject! { |a| a.is_a?(Symbol) and not has_method?(a) }
      if alternatives.empty?
        __send__(attribute)
      else
        process_attribute(attribute, alternatives.first)
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
  
  class UnmappedAttributeError < RuntimeError
  end
  
end
