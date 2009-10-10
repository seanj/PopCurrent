# ==Indexing into Ferret
# Ferret by Dave Balmain is a highly configurable, powerful port of Lucene to Ruby and C.
# It stores it's indexes in it's own format, so integrating it with ActiveRecord is not very
# easy - however this Indexer should give you a reasonable start. Take care to configure the underlying
# Ferret::Index::Index object yourself to achieve optimum search results.
# 
# Primarily because Ferret is so flexible, this indexer also accepts a "by" option, which will
# allow you to customize the index update procedure when records are updated. The Ferret index and the record are going to be
# passed to the proc.
# 
# This indexer does not use the ActiveRecord::Base#index_repr method, but instead
# will delegate tokenization and typecasting to Ferret. This, by default, will give you very good string representations
# of objects such as Date, Time etc.
# 
# However, if you define "index_repr_of_attribute" for one or more attributes the indexer is going to use them.
# 
# ==Options
#   :columns - attributes to index (pulled from list of fields by default)
#   :except - attributes to exclude from index
#   :including_associations - if the associated objects should be included in the index
#   :separate_columns - if separate columns should be created the columns will be saved
#         as Ferret document fields. Othwerise all will be indexed
#         into one document field called "content"
#   :by - can contain a proc, that will get the Ferret index and the record passed
#   :into - path to Ferret index
#   :ferret_options - hash of Ferret options to pass to the Ferret::Index::Index on creation

class ActiveSearch::FerretIndexer < ActiveSearch::Indexer

  attr_accessor :ferret_index, :index_searcher, :query_parser

  DEFAULT_INDEX_EXTENSION = 'ferret'
  
  DEFAULT_FERRET_OPTIONS = {
      :path => File.join(RAILS_ROOT, 'tmp', "ferret-indexes"),
      :default_field=>'*',
      :key=>'id',
      :auto_flush => true,
  }
  
  DEFAULT_OPTIONS = {
      :columns => :default,
      :into => DEFAULT_FERRET_OPTIONS[:path],
      :including_associations => true,
      :ferret_options => DEFAULT_FERRET_OPTIONS,
      :separate_columns => false,
      :by => nil,
  }

  def perform_setup(options)
    options[:ferret_options] = DEFAULT_FERRET_OPTIONS.merge(options[:ferret_options])
    
    options[:ferret_options][:path] = options[:into] if options[:into]
    options[:ferret_options][:key] = klass.primary_key

    @path = options[:ferret_options][:path]
    @separately = options[:separate_columns]
    @indexing_proc = options[:by]
    
    unless File.exist?(@path) && File.directory?(@path)
      options[:ferret_options][:create] = true
      Dir.mkdir(@path)
    end
    
    @ferret_index = Ferret::Index::Index.new(creation_options[:ferret_options])    
  end
  
  def handle_delete(record)
    pk = record[record.class.primary_key]
    @ferret_index.delete(pk.to_s) # as STRING
  end
  
  def rebuild!
    self.prune! # first wipe the index clean
  
    klass.find(:all).each do |r|
      doc = record_to_ferret_document(r)
      @ferret_index << doc
    end
  end
  
  # Prunes the index
  def prune!
 #  @ferret_index.close
    @ferret_index.query_delete(query_for_class_tree)
  end

  def update_by_id(record)
    handle_delete(record)
    
    doc = record_to_ferret_document(record)

    @ferret_index << doc
    @ferret_index.flush()
#   @ferret_index.close()
  end
  
  def handle_after_create(record)
    update_by_id(record)
  end
  
  def handle_create(record)
  end
  
  def handle_update(record)
    update_by_id(record)
  end
  
  # Returns the actual Ferret index
  def ferret_index
    @ferret_index
  end
  
  def size
    @ferret_index.size
    #Ferret::Index::IndexReader.open(creation_options[:ferret_options][:path]).num_docs
  end
  
  def query(query, options = {})
    
    raise_on_empty_term(query)
    
    @index_searcher ||= Ferret::Search::IndexSearcher.new(@path)

    unless @query_parser
      reader = @index_searcher.reader
      fields = begin
        reader.get_field_names.to_a
      rescue NoMethodError
        @separately ? @columns.map{ |c| c.to_s } : ['contents']
      end
      
      @query_parser ||= Ferret::QueryParser.new(fields)
    end
    
    parsed_query = @query_parser.parse(query)
    
    results = []
    
    # Install a filter to honor STI
    filter = Ferret::Search::QueryFilter.new(@query_parser.parse(query_for_class_tree))
    
    @index_searcher.search_each(parsed_query, filter) do |doc, score|
       document = @index_searcher.reader.get_document(doc)
       # wrap in result
       res = ActiveSearch::FerretResult.new(klass.find(document[klass.primary_key]), document)
       results << res
    end
    return results
  end


  private
    
    def query_for_class_tree
      descendants_or_self = ([klass] + subclasses_of(klass)).collect{|k| k.to_s }.map{|d| "class:"+d}
      descendants_or_self.join('|')
    end
    
    def with_exclusive_write_access(&block)
      yield
    end
    
    def record_to_ferret_document(record)
      
      # delegate to the proc if defined
      if @indexing_proc.respond_to?(:call)
        doc = @indexing_proc.call(@ferret_index, record, @columns) 
        unless doc.is_a?(Ferret::Document::Document)
          raise IndexRefreshError, "The object returned by the indexing proc should be a Ferret::Document!"
        end
        return doc
      end

            
      field_parameters = [
        Ferret::Document::Field::Store::COMPRESS,
        Ferret::Document::Field::Index::TOKENIZED,
        Ferret::Document::Field::TermVector::WITH_OFFSETS,
      ]
      
      # TEXTs and BLOBs, collections
      field_parameters_for_big_attributes = field_parameters      
      # usual field parameters      
      field_parameters_for_small_attributes = field_parameters      
      # collect assocs
      record_assocs = record.class.reflect_on_all_associations.collect{|a| a.name.to_s }

      doc = Ferret::Document::Document.new
      doc << Ferret::Document::Field.new('class', record.class.to_s, *field_parameters_for_small_attributes)
      doc << Ferret::Document::Field.new(klass.primary_key, record.send(klass.primary_key), *field_parameters_for_small_attributes)

      fields = {}

      @columns.each do | col |
        # specifics first
        if record.respond_to?("index_repr_of_#{col}")
          fields[col] = record.send("index_repr_of_#{col}")
        # collections second - as multiple field values
        elsif record_assocs.include?(col.to_s) and record.send(col).is_a?(Array) and @downstream
          fields[col] = []
          record.send(col).each { |subrecord| fields[col] << subrecord.index_repr }
        # associations third
        elsif record_assocs.include?(col.to_s) and @downstream
          fields[col] = record.send(col).index_repr
        # conventionals last
        elsif !record_assocs.include?(col.to_s) 
          fields[col] = record.send(col)
        end
      end

      if @separately      
        fields.each_pair do |k, v|
          if v.is_a?(Array)
            v.each{|part| doc << Ferret::Document::Field.new(k, part, *field_parameters) }
          else
            doc << Ferret::Document::Field.new(k, v, *field_parameters)
          end
        end
      else
        doc << Ferret::Document::Field.new('contents', fields.values.join("\n"), *field_parameters)
      end

      doc
    end
end

# Offers result_score and other Ferret meta (accessible through Result#document), while passing
# all the other messages to the ActiveRecord underneath.
class ActiveSearch::FerretResult < ActiveSearch::Result
  def initialize(record, ferret_document)
    @active_record, @document, @result_score = record, ferret_document, 0
  end
end