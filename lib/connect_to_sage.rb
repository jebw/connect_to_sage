module ConnectToSage
  
  def self.included(base)
    base.class_eval do
      extend Customers
      extend Invoices
      extend SalesOrders
    end
  end
  
end
