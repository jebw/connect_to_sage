class SageDownloadGenerator < Rails::Generator::Base
  attr_accessor :customer_model, :order_model, :order_type

  def initialize(runtime_args, runtime_options = {})
    super
    
    @order_type = (args.shift == 'sales_orders') ? 'sales_orders' : 'invoices'
    
    @customer_model = args.shift
    @order_model = args.shift
  end

  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', 
                           :migration_file_name => "create_sage_downloads"
      m.template 'sage_download.rb', File.join('app', 'models', 'sage_download.rb')
    end
  end
  
  protected
  
    def banner
      "Usage: #{$0} sage_download (invoices || sales_orders) CUSTOMERMODEL ORDERMODEL"
    end
    
end
