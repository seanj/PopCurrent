# A container for ActiveRecords that get retrieved. When getting results of Ferret searches we also
# would like to have access to the additional details, such as search score. The record we have fetched
# is not made to bear these attributes from the get-go, so we deccorate it with a Result

class ActiveSearch::Result
  attr_accessor :result_score
  attr_accessor :document

  include Comparable
  
  def self.wrap_find(records)
    records.collect{|r| self.new(r)}
  end
  
  def initialize(record)
    @active_record = record
  end

	# Gives access to the ActiveRecord
	def record
		@active_record
	end
  
	# Gives passthrough access to the ActiveRecord class
  def class
    @active_record.class
  end
  
  def method_missing(*args) #:nodoc:
    @active_record.send(*args)
  end
  
  def self.method_missing(*args) #:nodoc:
    @active_record.class.send(*args)
  end    
  
	# Allows comparisons to another ActiveRecord
  def <=>(other)
    result_score <=> other.result_score
  end
end