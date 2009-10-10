$KCODE = 'u' # YES please, thank you.

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
presumed_rails_dir = File.expand_path(File.dirname(__FILE__)+'/../../../rails')

if File.directory?(presumed_rails_dir)
  $:.unshift(presumed_rails_dir)  
  puts "Using Edge Rails from vendor"  
  require 'activerecord/lib/active_record'
  require 'activerecord/lib/active_record/fixtures'
  require 'activesupport/lib/active_support'
  require 'activesupport/lib/active_support/breakpoint'
else
  puts "Using Rubygems"
  require 'rubygems'
  require 'active_record'
  require 'active_record/fixtures'
  require 'active_support'
  require 'active_support/breakpoint'
end

tempdir = File.join(File.dirname(__FILE__), 'tmp')
Dir.mkdir(tempdir) unless File.directory?(tempdir)
RAILS_ROOT = File.dirname(tempdir)

begin
	require 'ferret'
	$WITH_FERRET = true
	puts "Ferret tests will run"
rescue LoadError
	$WITH_FERRET = false
	puts "Ferret tests will be skipped"
end

require File.dirname(__FILE__)  + "/../init"

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

db_adapter = ENV['ASEARCH_DB_DRIVER'] ? ENV['ASEARCH_DB_DRIVER'] : 'sqlite3'
puts "Testing with database driver #{db_adapter}, define ASEARCH_DB_DRIVER in your environment to test with another database"  

driver = config[db_adapter]
ActiveRecord::Base.establish_connection(driver)

ActiveRecord::Base.logger.silence {
  load(File.dirname(__FILE__) + "/schema.rb")
}

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)


class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false

end