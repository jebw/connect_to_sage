module ConnectToSage

  module Invoices

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

  end

end
