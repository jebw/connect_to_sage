class AddSageDownloadModel < ActiveRecord::Migration

  def self.up
    create_table :sage_downloads do |t|
      t.text :xml
      t.timestamps
    end
  end
  
  def self.down
    drop_table :sage_downloads
  end

end
