class AddItunesLinkToSubmissions < ActiveRecord::Migration
  def self.up
    add_column :submissions, :itunes_url, :string, :limit => 255, :default => "", :null => false
  end
  
  def self.down
    remove_column :submissions, :itunes_url
  end
end