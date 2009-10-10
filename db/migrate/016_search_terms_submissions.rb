class SearchTermsSubmissions < ActiveRecord::Migration
  def self.up
    create_table :search_terms_submissions do |t|
      t.column "search_term_id", :int, :limit => 11
      t.column "submission_id", :int, :limit => 11
    end
  end

  def self.down
    drop_table :search_terms_submissions
  end
end