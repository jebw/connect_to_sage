class SageGenerator < Rails::Generator::Base
  attr_accessor :controller_name, :controller_file_name, :controller_url, :password,
                :order_type, :customer_model, :order_model
  
  def initialize(runtime_args, runtime_options = {})
    super
  
    @controller_url = (args.shift || 'sage').underscore
    @controller_name = @controller_url.camelize + 'Controller'
    @controller_file_name = @controller_name.underscore
    
    @order_type = options[:sales_orders] ? 'sales_orders' : 'invoices'
    
    @customer_model = (args.shift || find_customer_model).camelize.singularize
    @customer_model_table = @customer_model.underscore.pluralize
    @customer_join_table = [ 'sage_downloads', @customer_model_table ].sort.join('_')
    
    @order_model = (args.shift || find_order_model).camelize.singularize
    @order_model_table = @order_model.underscore.pluralize
    @order_join_table = [ 'sage_downloads', @order_model_table ].sort.join('_')
    
    @password = generate_password
  end
  
  def manifest
    recorded_session = record do |m|
      unless options[:no_download] and options[:no_upload]
        m.migration_template 'migration.rb', 'db/migrate',
                             :assigns => { :customer_model => @customer_model, :order_model => @order_model,
                             :customer_join_table => @customer_join_table, :customer_model_table => @customer_model_table,
                             :order_join_table => @order_join_table, :order_model_table => @order_model_table },
                             :migration_file_name => "create_sage_models"
      end
      unless options[:no_download]
        m.template 'sage_download.rb', File.join('app', 'models', 'sage_download.rb')
        m.template 'sage_import.rb', File.join('app', 'models', 'sage_import.rb')
      end
      m.template 'controller.rb', File.join('app', 'controllers', "#{@controller_file_name}.rb")
    end
    
    puts ""
    puts "Upload URL: /#{@controller_url}/upload" unless options[:no_upload]
    unless options[:no_download]
      puts "Download URL: /#{@controller_url}/download"
      puts "Import URL: /#{@controller_url}/import"
    end
    puts ""
    puts "Your controller is protected with http authentication, edit the"
    puts "authenticate method in app/controllers/#{@controller_file_name}"
    puts "to change this"
    puts ""
    puts "      Username: sageuser"
    puts "      Password: #{@password}"
    puts ""
    
    recorded_session
  end
  
  protected
  
    def banner
      "Usage: #{$0} sage_controller [ControllerName] [CustomerModelName] [OrderModelName]"
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on('--no-upload', 'Only generate code for downloading from Sage Line 50') { |v| options[:no_upload] = true }
      opt.on('--no-download', 'Only generate code for uploading to Sage Line 50') { |v| options[:no_download] = true }
      opt.on('--sales-orders', 'Generate Sales Orders in Sage instead of Invoices') { |v| options[:sales_orders] = true }
    end
    
    def generate_password(pass_length = 8)
      char_list = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
			generate_pass = ""
			1.upto(pass_length) { |i| generate_pass << char_list[rand(char_list.size)] }
			return generate_pass
    end
    
    def find_customer_model
      return 'Customer' if File.exist?(File.join('app', 'models', 'customer.rb'))
      return 'User' if File.exist?(File.join('app', 'models', 'user.rb'))
      raise MissingModel, "Specify a Customer Model, none found"
    end
    
    def find_order_model
      return 'Order' if File.exist?(File.join('app', 'models', 'order.rb'))
      raise MissingModel, "Specify an Order Model, none found"
    end

end

class MissingModel < RuntimeError
end

