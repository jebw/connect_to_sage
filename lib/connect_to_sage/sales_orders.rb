module ConnectToSage

  module SalesOrders
  
    def sage_sales_order(attr_map = {})
      @@sales_order_map = attr_map
      include AttributeMapper
      
      has_and_belongs_to_many :sage_downloads
      belongs_to :sage_import
            
      define_method "to_sales_order_xml" do |xml|
        @@sales_order_map ||= xml
              
        xml.SalesOrder do
          xml.Id sales_order_map(:id)
          xml.Forename sales_order_map(:forename)
          xml.Surname sales_order_map(:surname)
          xml.RandomField sales_order_map(:random_field) rescue NoMethodError
          xml.Desc sales_order_map(:desc)
        end
      end
      
      define_method "sales_order_map" do |*alternatives|
        attribute_map(@@sales_order_map, alternatives)
      end
      
    end
    
  end
  
end
