class CreateAdvertisements < ActiveRecord::Migration
  def self.up
    create_table :advertisements do |t|
      t.column "desc", :string, :limit => 255, :default => "", :null => false
      t.column "priority", :int, :limit => 4
      t.column "placement", :string, :limit => 255, :default => "", :null => false
      t.column "width", :string, :limit => 8, :default => "", :null => false
      t.column "height", :string, :limit => 8, :default => "", :null => false
      t.column "codeblock", :text, :null => false
      t.column "enabled", :int, :limit => 1, :default => 0
      t.column "start_at", :datetime
      t.column "expire_at", :datetime
    end
  end

  def self.down
    drop_table :advertisements
  end
end
