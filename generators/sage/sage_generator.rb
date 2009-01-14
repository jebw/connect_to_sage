class SageGenerator < Rails::Generator::Base
  attr_accessor :controller_name, :controller_file_name, :controller_url, :password
  
  def initialize(runtime_args, runtime_options = {})
    super
  
    @controller_url = (args.shift || 'sage').underscore
    @controller_name = @controller_url.camelize + 'Controller'
    @controller_file_name = @controller_name.underscore
    
    @password = generate_password
  end
  
  def manifest
    recorded_session = record do |m|
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
      "Usage: #{$0} sage_controller [CONTROLLERNAME] [CUSTOMERMODEL] [ORDERMODEL]\n"
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

end
