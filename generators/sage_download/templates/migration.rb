class AddSageDownloadModel < ActiveRecord::Migration

  def self.up
    create_table :sage_downloads do |t|
      t.text :xml
      t.timestamps
    end
    
    create_table :sage_imports do |t|
      t.text :xml
      t.timestamps
    end
    
    #create join table between orders and sage_downloads
    create_table <%= order_join_table %>, :id => false do |t|
      t.integer 'sage_download_id'
      t.integer '<%= order_model.underscore %>_id'
    end
    
    create_table <%= customer_join_table %>, :id => false do |t|
      t.integer 'sage_download_id'
      t.integer '<%= customer_model.underscore %>_id'
    end
    
    add_column :<%= order_model_table %>, :sage_import_id, :integer
    add_column :<%= customer_model_table %>, :sage_import_id, :integer
  end
  
  def self.down
    remove_column :<%= customer_model_table %>, :sage_import_id
    remove_column :<%= order_model_table %>, :sage_import_id
    
    drop_table :<%= customer_join_table %>
    drop_table :<%= order_join_table %>
  
    drop_table :sage_downloads
    drop_table :sage_imports
  end

end