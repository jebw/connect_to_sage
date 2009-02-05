class SageDownload < ActiveRecord::Base
  include ConnectToSage::DownloadXml

  has_and_belongs_to_many :<%= order_type %>, :class_name => '<%= order_model %>'
  
  before_create :associate_models
  before_create :store_xml

  def to_xml(options = {})
    read_attribute :xml
  end
  
  protected
    
    def associate_models
      <%= order_type %> << <%= order_model %>.all(:conditions => { :sage_import_id => nil }, :limit => 1000)
    end
    
    def customers
      @customers ||= find_customers
    end
    
    def find_customers
      customers = []
      customers += invoices.map { |i| i.<%= customer_model.underscore %> } if self.methods.include?('invoices')
      customers += sales_orders.map { |so| so.<%= customer_model.underscore %> } if self.methods.include?('sales_orders')
      customers.uniq
    end
  
end
