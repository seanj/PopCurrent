class Categories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column "category_name", :string, :limit => 255, :default => "", :null => false
    end
  end

  def self.down
    drop_table :categories
  end
end
