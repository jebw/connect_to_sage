class SageImport < ActiveRecord::Base

  has_many :<%= order_type %>, :class_name => '<%= order_model %>'
  has_many :customers, :class_name => '<%= customer_model %>'
  validates_presence_of :xml

  before_save :parse_uploaded_xml
  
  protected
    
    def parse_uploaded_xml
      # FIXME parse the uploaded xml and associate the appropriate customers
      
      importdoc = REXML::Document.new(read_attribute(:xml))
            
      if methods.include?('invoices')
        importdoc.elements.each('Company/Invoices/Invoice/Id') do |iid|
          invoices << Invoice.find(iid.text.to_i) rescue ActiveRecord::RecordNotFound
        end
      end      
      
      if methods.include?('sales_orders')
        importdoc.elements.each('Company/SalesOrders/SalesOrder/Id') do |oid|
          sales_orders << Order.find(oid.text.to_i) rescue ActiveRecord::RecordNotFound
        end
      end      
      
    end

end
