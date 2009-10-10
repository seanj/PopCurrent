class SearchTermsUsers < ActiveRecord::Migration
  def self.up
    create_table :search_terms_users do |t|
      t.column "search_term_id", :int, :limit => 11
      t.column "user_id", :int, :limit => 11
    end
  end

  def self.down
    drop_table :search_terms_users
  end
end