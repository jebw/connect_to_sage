class SageImport < ActiveRecord::Base

  has_many :<%= order_type %>, :class_name => '<%= order_model %>'
  has_many :customers, :class_name => '<%= customer_model %>'

  :before_save parse_uploaded_xml
  
  protected
    
    def parse_uploaded_xml
      # FIXME parse the uploaded xml and associate the appropriate customers and invoices/sales_orders
    end

end
