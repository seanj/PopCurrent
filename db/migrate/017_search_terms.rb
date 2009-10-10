class SearchTerms < ActiveRecord::Migration
  def self.up
    create_table :search_terms do |t|
      t.column :term, :string
    end
  end

  def self.down
    drop_table :search_terms
  end
end