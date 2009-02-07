module ConnectToSage

  module Contact
  
    private
      
      def sage_contact_xml(xml, mapper)
        xml.Title mapper.match(:title) rescue UnmappedAttribute
        xml.Forename mapper.match(:forename) rescue UnmappedAttribute
        xml.Surname mapper.match(:surname) rescue UnmappedAttribute
        xml.Company mapper.match(:company) rescue UnmappedAttribute
        xml.Address1 mapper.match(:address1, :address_1, :address_line_1, :address_line1, :line1, :line_1) rescue UnmappedAttribute
        xml.Address2 mapper.match(:address2, :address_2, :address_line_2, :address_line2, :line2, :line_2) rescue UnmappedAttribute
        xml.Town mapper.match(:town) rescue UnmappedAttribute
        xml.Postcode mapper.match(:postcode) rescue UnmappedAttribute
        xml.County mapper.match(:county) rescue UnmappedAttribute
        xml.Country mapper.match(:country) rescue UnmappedAttribute
        xml.Telephone mapper.match(:telephone) rescue UnmappedAttribute
        xml.Email mapper.match(:email) rescue UnmappedAttribute
      end
  
  end
  
end
