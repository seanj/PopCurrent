class Submissions < ActiveRecord::Migration
  def self.up
    create_table :submissions do |t|
      t.column "url", :string, :limit => 255, :default => "", :null => false
      t.column "magnet_url", :string, :limit => 255, :default => "", :null => false
      t.column "rss_url", :string, :limit => 255, :default => "", :null => false
      t.column "torrent_url", :string, :limit => 255, :default => "", :null => false
      t.column "user_id", :int, :limit => 11
      t.column "title", :string, :limit => 255, :default => "", :null => false
      t.column "description", :text, :null => false
      t.column "category", :string, :limit => 30, :default => "0", :null => false
      t.column "image_url", :string, :limit => 255, :default => ""
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "pfc", :tinyint
      t.column "status", :integer, :limit => 40
      t.column "deleted", :datetime
      t.column "vote_total", :int, :limit => 11, :default => 0
    end
  end

  def self.down
    drop_table :submissions
  end
end
