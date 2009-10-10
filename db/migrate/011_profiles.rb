class Profiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column "user_id", :int, :limit => 11
      t.column "image_url", :string, :limit => 255, :default => ""
      t.column "description", :text, :null => false
      t.column "dateofbirth", :datetime
      t.column "location", :string, :limit => 128, :default => ""
      t.column "country", :string, :limit => 128, :default => ""
      t.column "vote_total", :int, :limit => 11, :default => 0
      t.column "allow_email", :tinyint, :default => 0
    end
  end

  def self.down
    drop_table :profiles
  end
end
