module ConnectToSage

  module Invoices

    def sage_invoice(options = {}, &attr_map)
      attr_accessor :sage_xml_builder
    
      @@invoice_map = AttrMapper.new(options, &attr_map)
      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_invoice_xml" do |xml|
        @sage_xml_builder ||= xml
        
        xml.Invoice do
          @@invoice_map.match_for(self) do |m|
            xml.Id m.match(:id, :sage_id)
            xml.CustomerId m.match(:customer_id)
            xml.InvoiceNumber m.match(:invoice_number) rescue UnmappedAttribute
            xml.CustomerOrderNumber m.match(:customer_order_number) rescue UnmappedAttribute
            xml.AccountReference m.match(:account_reference) rescue UnmappedAttribute
            xml.OrderNumber m.match(:order_number, :id)# rescue UnmappedAttribute
            xml.ForeignRate m.match(:foreign_rate) rescue UnmappedAttribute
            xml.Currency m.match(:currency) rescue UnmappedAttribute
            xml.Notes1 m.match(:notes1) rescue UnmappedAttribute
            xml.CurrencyUsed m.match(:currency_used) rescue UnmappedAttribute
            xml.InvoiceDate m.match(:invoice_date, :created_at) rescue UnmappedAttribute
            xml.InvoiceType m.match(:invoice_type) rescue UnmappedAttribute
            xml.InvoiceAddress do
              m.match(:invoice_address, :to_invoice_address_xml)
            end
            xml.InvoiceDeliveryAddress do
              m.match(:invoice_delivery_address, :to_invoice_delivery_address_xml)
            end
            xml.Courier m.match(:courier) rescue UnmappedAttribute
            xml.SettlementDays m.match(:settlement_days) rescue UnmappedAttribute
            xml.SettlementDiscount m.match(:settlement_discount) rescue UnmappedAttribute
            xml.GlobalTaxCode m.match(:global_tax_code) rescue UnmappedAttribute
            xml.GlobalDepartment m.match(:global_department) rescue UnmappedAttribute
            xml.PaymentAmount m.match(:payment_amount) rescue UnmappedAttribute
          end
        end
      end
    end
    
    def sage_invoice_address(options = {}, &attr_map)
      include Contact
      @@invoice_address_map = AttrMapper.new(options, &attr_map)
      
      define_method "to_invoice_address_xml" do |xml|
        @sage_xml_builder ||= xml
      
        @@invoice_address_map.match_for(self) do |m|
          sage_contact_xml(xml, m)
        end
      end      
    end
    
    def sage_invoice_delivery_address(options = {}, &attr_map)
      include Contact
      @@invoice_delivery_address_map = AttrMapper.new(options, &attr_map)
      
      define_method "to_invoice_delivery_address_xml" do |xml|
        @sage_xml_builder ||= xml
        
        @@invoice_delivery_address_map.match_for(self) do |m|
          sage_contact_xml(xml, m)
        end
      end
    end

  end

end
