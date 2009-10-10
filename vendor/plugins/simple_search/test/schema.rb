ActiveRecord::Schema.define(:version => 1) do
  create_table :pages, :force => true do |t|
    t.column :title, :string
    t.column :body, :text
    t.column :page_author_id, :integer
    t.column :approved, :boolean
    t.column :an_index, :text
    t.column :another_index, :text
  end

  create_table :page_authors, :force => true do |t|
    t.column :first_name, :string
    t.column :last_name, :string
    t.column :bio, :text
    t.column :birth_date, :date
    t.column :other_searchable, :text
  end

  create_table :page_paras, :force => true do |t|
    t.column :page_id, :integer
    t.column :position, :integer
    t.column :content, :text
  end

  create_table :search_terms, :force => true do |t|
    t.column :term, :string
  end

  create_table :pages_search_terms, :force => true, :id=>false do |t|
    t.column :search_term_id, :string
    t.column :page_id, :integer
  end

end