class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column "submission_id", :int, :limit => 11
      t.column "root_id", :int, :limit => 11
      t.column "parent_id", :int, :limit => 11
      t.column "depth", :int, :limit => 11
      t.column "lft", :int, :limit => 11
      t.column "rgt", :int, :limit => 11
      t.column "lft", :int, :limit => 11
      t.column "updated_at", :datetime
      t.column "created_at", :datetime
      t.column "user_name", :string, :limit => 80, :default => "", :null => false
      t.column "user_id", :int, :limit => 11
      t.column "subject", :string, :limit => 255, :default => "", :null => false
      t.column "body", :text, :null => false
    end
  end

  def self.down
    drop_table :comments
  end
end
