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
            invoice_map(:invoice_address, :to_invoice_address_xml)
          end
          xml.InvoiceDeliveryAddress do
            invoice_map(:invoice_delivery_address, :to_invoice_delivery_address_xml)
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
      sage_contact_xml('invoice_address')
      
      define_method "invoice_address_map" do |*alternatives|
        attribute_map(@@invoice_address_map, alternatives)
      end
    end
    
    def sage_invoice_delivery_address(attr_map = {})
      @@invoice_delivery_address_map = attr_map
      sage_contact_xml('invoice_delivery_address')
      
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
          xml.CompanyName customer_map(:company_name) rescue NoMethodError
          xml.AccountReference customer_map(:account_reference) rescue NoMethodError
          xml.VatNumber customer_map(:vat_number) rescue NoMethodError
          xml.CustomerInvoiceAddress do
            customer_map(:customer_invoice_address, :to_customer_invoice_address_xml)
          end
          xml.CustomerDeliveryAddress do
            customer_map(:customer_delivery_address, :to_customer_delivery_address_xml)
          end
        end
      end
      
      define_method "customer_map" do |*alternatives|
        attribute_map(@@customer_map, alternatives)
      end
    end
    
    def sage_customer_invoice_address(attr_map = {})
      @@customer_invoice_address_map = attr_map
      sage_contact_xml('customer_invoice_address')
      
      define_method "customer_invoice_address_map" do |*alternatives|
        attribute_map(@@customer_invoice_address_map, alternatives)
      end
    end
    
    def sage_customer_delivery_address(attr_map = {})
      @@customer_delivery_address_map = attr_map
      sage_contact_xml('customer_delivery_address')
      
      define_method "customer_delivery_address_map" do |*alternatives|
        attribute_map(@@customer_delivery_address_map, alternatives)
      end
    end
    
    def sage_contact_xml(contact_type)
      include AttributeMapper
      
      define_method "to_#{contact_type}_xml" do |xml|
        @sage_xml_builder ||= xml
        contact_map = "#{contact_type}_map"
          
        xml.Title __send__(contact_map, :title) rescue NoMethodError
        xml.Forename __send__(contact_map, :forename) rescue NoMethodError
        xml.Surname __send__(contact_map, :surname) rescue NoMethodError
        xml.Company __send__(contact_map, :company) rescue NoMethodError
        xml.Address1 __send__(contact_map, :address1, :address_1, :address_line_1, :address_line1, :line1, :line_1) rescue NoMethodError
        xml.Address2 __send__(contact_map, :address2, :address_2, :address_line_2, :address_line2, :line2, :line_2) rescue NoMethodError
        xml.Town __send__(contact_map, :town) rescue NoMethodError
        xml.Postcode __send__(contact_map, :postcode) rescue NoMethodError
        xml.County __send__(contact_map, :county) rescue NoMethodError
        xml.Country __send__(contact_map, :country) rescue NoMethodError
        xml.Telephone __send__(contact_map, :telephone) rescue NoMethodError
        xml.Email __send__(contact_map, :email) rescue NoMethodError
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
  
  class UnmappedAttributeError < RuntimeError
  end
  
end
