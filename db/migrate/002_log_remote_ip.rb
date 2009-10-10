class LogRemoteIp < ActiveRecord::Migration
  def self.up
    add_column :users, :registered_from_ip, :string, :limit => 255, :default => "", :null => false
  end

  def self.down
    remove_column :users, :registered_from_ip
  end
end