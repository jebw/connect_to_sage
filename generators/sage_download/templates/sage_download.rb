class SageDownload < ActiveRecord::Base
  has_and_belongs_to_many :<%= order_type %>, :class_name => '<%= order_model %>'
  has_and_belongs_to_many :customers, :class_name => '<%= customer_model %>'
  
  before_create :associate_models
  before_create :store_xml

  def to_xml(options = {})
    read_attribute :xml
  end
  
  protected
    
    def associate_models
      customers << <%= customer_model %>.all(:conditions => { :sage_import_id => nil })
      <%= order_type %> << <%= order_model %>.all(:conditions => { :sage_import_id => nil })
    end
    
    def store_xml
      write_attribute :xml, create_xml
    end
    
    def create_xml
      x = Builder::XmlMarkup.new(:indent => 2)
      x.instruct!
      
      x.Company("xmlns:xsd" => "http://www.w3.org/2001/XMLSchema", 
                "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do
        
        unless customers.empty?
          x.Customers do
            customers.each do |customer|
              customer.to_customer_xml(x)
            end        
          end
        end
        
        if self.methods.include?('invoices') and not invoices.empty?
          x.Invoices do
            invoices.each do |invoice|
              invoice.to_invoice_xml(x)
            end
          end
        end
        
        if self.methods.include?('sales_orders') and not sales_orders.empty?
          x.SalesOrders do
            sales_orders.each do |sales_order|
              sales_order.to_sales_order_xml(x)
            end
          end
        end
        
      end
      
    end
  
end
