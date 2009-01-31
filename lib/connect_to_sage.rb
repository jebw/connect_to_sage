module ConnectToSage
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      extend Customers
      extend Invoices
      extend SalesOrders
    end
  end

  module ClassMethods
  
    private
  
      def sage_contact_xml(contact_type)
        include AttributeMapper
        
        define_method "to_#{contact_type}_xml" do |xml|
          @sage_xml_builder ||= xml
          contact_map = "#{contact_type}_map"
            
          xml.Title __send__(contact_map, :title) rescue NoMethodError
          xml.Forename __send__(contact_map, :forename) rescue NoMethodError
          xml.Surname __send__(contact_map, :surname) rescue NoMethodError
          xml.Company __send__(contact_map, :company) rescue NoMethodError
          xml.Address1 __send__(contact_map, :address1, :address_1, :address_line_1, :address_line1, :line1, :line_1) rescue NoMethodError
          xml.Address2 __send__(contact_map, :address2, :address_2, :address_line_2, :address_line2, :line2, :line_2) rescue NoMethodError
          xml.Town __send__(contact_map, :town) rescue NoMethodError
          xml.Postcode __send__(contact_map, :postcode) rescue NoMethodError
          xml.County __send__(contact_map, :county) rescue NoMethodError
          xml.Country __send__(contact_map, :country) rescue NoMethodError
          xml.Telephone __send__(contact_map, :telephone) rescue NoMethodError
          xml.Email __send__(contact_map, :email) rescue NoMethodError
        end
      end
  
  end
  
end
