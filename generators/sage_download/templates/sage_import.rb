class SageImport < ActiveRecord::Base

  has_many ":#{order_type}"

end
