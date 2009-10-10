class ProfileFlops < ActiveRecord::Migration
  def self.up
      create_table :profile_flops do |t|
        t.column "user_id", :int, :limit => 11
        t.column "profile_id", :int, :limit => 11
        t.column "created_at", :datetime
      end
    end

    def self.down
      drop_table :profile_flops
    end
end
