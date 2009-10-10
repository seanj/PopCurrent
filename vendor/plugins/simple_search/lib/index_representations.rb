## Index representations for basic types
class Object::Time #:nodoc:
  def index_repr
    strftime("%d %A %B %Y")
  end
end

module ActiveSearch::IndexUnworthy  #:nodoc:
  def index_repr
    ''
  end
end

[TrueClass, FalseClass, NilClass].each {|c| c.send(:include, ActiveSearch::IndexUnworthy) }

class Object::Date #:nodoc:
  def index_repr
    strftime("%d %A %B %Y")
  end
end

class Object::Array #:nodoc:
  def index_repr
    collect do |i|
      i.respond_to?(:index_repr) ? i.send(:index_repr) : i.to_s
    end.reject do |i|
      i.blank?
    end.join(" ")
  end
end

class Object::ActiveRecord::Base
  # This method should return the optimum string representation of an object for searching,
  # with words in lowercase separated by spaces. By default all ActiveRecords get a default
  # implementation, but if you want you can easily override it for every model that you have defined.
  # An indexer requesting the representation will be passed to the method
  # There can also be asked for the sanitized result - if so, an array shall be returned. Else a string should be returned.
  def index_repr(for_indexer = nil, sanitized = true)
    search_matrix = []

    # If we have an explicit list of fields to search, we do it
    if for_indexer
      columns_to_introspect = for_indexer.indexed_columns      
    elsif self.class.indexers.any?
      columns_to_introspect = self.class.indexers.inject([]) { |c, idx| c += idx.indexed_columns }.uniq
    else
      columns_to_introspect = ActiveSearch::Indexer.automatically_indexed_columns(self.class)
    end

    columns_to_introspect -= ActiveSearch::excluded_attributes_of(self.class)
    
    # We harvest columns that respond to to_s and collections.
    logger.warn columns_to_introspect.inspect
		
		columns_to_introspect.each do |col|
      next unless self.respond_to?(col) or self.send(col).nil?
      value = self.respond_to?("index_repr_of_#{col}") ? self.send("index_repr_of_#{col}") : self.send(col)

      next if value.blank?
      
      # Handle predicates like "valid", "checked", "approved"
      search_matrix << Inflector::humanize(col) if value.is_a?(TrueClass)

      if value.respond_to?(:index_repr)
        search_matrix << value.index_repr
      elsif value.respond_to?(:to_s)
        search_matrix << value.to_s
      end
    end
		
		sanitized ? ActiveSearch::Indexer.sanitize_index_representation(search_matrix) : search_matrix.join(" ")
  end
end