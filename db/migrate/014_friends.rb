class Friends < ActiveRecord::Migration
  def self.up
    create_table :friends do |t|
      t.column "user_id", :int, :limit => 11
      t.column "profile_id", :int, :limit => 11
    end
  end

  def self.down
    drop_table :friends
  end
end
