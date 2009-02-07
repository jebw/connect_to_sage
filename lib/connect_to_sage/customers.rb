module ConnectToSage

  module Customers
  
    def sage_customer(options = {}, &attr_map)
      attr_reader :sage_xml_builder
      @@customer_map = AttrMapper.new(options, &attr_map)
      
      define_method "to_customer_xml" do |xml|
        @sage_xml_builder ||= xml
      
        xml.Customer do
          @@customer_map.match_for(self) do |m|
            xml.Id m.match(:id)
            xml.CompanyName m.match(:company_name) rescue UnmappedAttribute
            xml.AccountReference m.match(:account_reference) rescue UnmappedAttribute
            xml.VatNumber m.match(:vat_number) rescue UnmappedAttribute
            xml.CustomerInvoiceAddress do
              m.match(:customer_invoice_address, :to_customer_invoice_address_xml)
            end
            xml.CustomerDeliveryAddress do
              m.match(:customer_delivery_address, :to_customer_delivery_address_xml)
            end
          end
        end
      end
    end
    
    def sage_customer_invoice_address(options = {}, &attr_map)
      include Contact
      @@customer_invoice_address_map = AttrMapper.new(options, &attr_map)
      
      define_method "to_customer_invoice_address_xml" do |xml|
        @sage_xml_builder ||= xml
        
        @@customer_invoice_address_map.match_for(self) do |m|
          sage_contact_xml(xml, m)
        end
      end
    end
    
    def sage_customer_delivery_address(options = {}, &attr_map)
      include Contact
      @@customer_delivery_address_map = AttrMapper.new(options, &attr_map)
      
      define_method "to_customer_delivery_address_xml" do |xml|
        @sage_xml_builder ||= xml
        
        @@customer_delivery_address_map.match_for(self) do |m|
          sage_contact_xml(xml, m)
        end
      end
    end
  
  end
  
end
