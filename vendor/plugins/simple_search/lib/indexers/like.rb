# ==Indexing into a column
# Dumps the index representation of an ActiveRecord::Base object into a separate column for searching. You can limit
# the length of the column to a VARCHAR, the index will then be truncated to match the length of the column.
#
# ==Options
# 	:columns - attributes to index (pulled from list of fields by default)
# 	:except - attributes to exclude from index
# 	:including_associations - if the associated objects should be included in the index
# 	:into - name of the attribute of the record that will hold the index text. Default - 'searchable'.
# 	

class ActiveSearch::LikeIndexer < ActiveSearch::Indexer
  DEFAULT_OPTIONS = {
		:columns => :default,
		:except => [],
		:into => 'searchable',
		:including_associations => true
	}

  def perform_setup(opts)
    @index_column = opts[:into].to_s
    @columns -= [@index_column] # We wont be indexing the index itself
    unless klass.column_names.include?(@index_column.to_s)
      raise ActiveSearch::IndexSetupError, "Your table #{klass.table_name} does not have a column #{@index_column} \
to store the index!" 
    end
    @used_columns = [@index_column]
  end
  
  def index_column_name
    @index_column.to_sym
  end
  
  def prune!
    klass.update_all("#{@index_column} = NULL")
  end

  def query(term)
		raise_on_empty_term(term)    
    terms = term_to_array(term)
    conditions = compose_conditions("#{@index_column} LIKE ?", terms, "%%s%")
    klass.find(:all, :conditions=>conditions)
  end

  def handle_update(record)
		repr = record.index_repr(self)
		
		unless record.class.columns.find{|c|c.name == @index_column}.limit.nil?
			limit = record.class.columns.find{|c|c.name == @index_column}.limit			
			repr.gsub!(/\s(\w+)$/, '') until repr.length < limit
		end
		
    record.send("#{@index_column}=".to_sym, repr)
  end
  
  def handle_create(record)
    handle_update(record)
  end
  
  def rebuild!
    klass.find(:all).each do |model|
      handle_update(model) && model.save(with_validation = false)
    end
  end
end
