class CreateSageModels < ActiveRecord::Migration

  def self.up
    <% unless options[:no_download] %>
    create_table :sage_downloads do |t|
      t.text :xml
      t.timestamps
    end
    
    create_table :sage_imports do |t|
      t.text :xml
      t.timestamps
    end
    
    create_table '<%= order_join_table %>', :id => false do |t|
      t.integer 'sage_download_id'
      t.integer '<%= order_model.underscore %>_id'
    end
    
    add_column :<%= order_model_table %>, :sage_import_id, :integer
    <% end %>
  end
  
  def self.down
    <% unless options[:no_download] %>
    remove_column :<%= order_model_table %>, :sage_import_id
    
    drop_table :<%= order_join_table %>
  
    drop_table :sage_downloads
    drop_table :sage_imports
    <% end %>
  end

end
