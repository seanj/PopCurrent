class SubPops < ActiveRecord::Migration
  def self.up
    create_table :sub_pops do |t|
      t.column "user_id", :int, :limit => 11
      t.column "submission_id", :int, :limit => 11
      t.column "created_at", :datetime
    end
  end

  def self.down
    drop_table :sub_pops
  end
end
