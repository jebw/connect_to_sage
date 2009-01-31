module ConnectToSage

  module Customers
  
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
  
  end
  
end
