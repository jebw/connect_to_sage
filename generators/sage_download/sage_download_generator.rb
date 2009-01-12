class SageDownloadGenerator < Rails::Generator::Base
  attr_accessor :customer_model, :order_model, :order_type

  def initialize(runtime_args, runtime_options = {})
    super
    
    @order_type = (args.shift == 'sales_orders') ? 'sales_orders' : 'invoices'
    
    @customer_model = args.shift
    @customer_model_table = @customer_model.underscore.pluralize
    @customer_join_table = [ 'sage_downloads', @customer_model_table ].sort.join('_')
    @order_model = args.shift
    @order_model_table = @order_model.underscore.pluralize
    @order_join_table = [ 'sage_downloads', @order_model_table ].sort.join('_')
  end

  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate',
                           :assigns => { :customer_model => @customer_model, :order_model => @order_model,
                           :customer_join_table => @customer_join_table, :customer_model_table => @customer_model_table,
                           :order_join_table => @order_join_table, :order_model_table => @customer_model_table },
                           :migration_file_name => "create_sage_downloads"
      #m.template 'sage_download.rb', File.join('app', 'models', 'sage_download.rb')
      #m.template 'sage_import.rb', File.join('app', 'models', 'sage_import.rb')
    end
  end
  
  protected
  
    def banner
      "Usage: #{$0} sage_download (invoices || sales_orders) CUSTOMERMODEL ORDERMODEL"
    end
    
end
