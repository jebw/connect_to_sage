class SageDownload < ActiveRecord::Base

  <%= order_type %> <%= order_model.underscore %> 

  def to_xml
    "<html><body><b>Hello</b> World</body></html>"
  end
  
end
