module ConnectToSage
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
  
    def sage_invoice(fieldmap = {})
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_invoice_xml" do |x|
        x.Invoice do
          
        end
      end
    end
    
    def sage_sales_order(fieldmap = {})
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_sales_order_xml" do |x|
        x.SalesOrder do
          x.BarFoo
        end
      end
    end
    
    def sage_customer(fieldmap = {})
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
      
      define_method "to_customer_xml" do |x|
        x.Customer do
          x.foobar
        end
      end
    end
  
  end
end
