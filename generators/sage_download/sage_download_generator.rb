class SageDownloadGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    
    @file_name = "AddSageDownloadModel"
  end

  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', 
                            :migration_file_name => "create_sage_downloads"
      m.template 'model.rb', File.join('app', 'models', 'sage_download.rb')
    end
  end
end
