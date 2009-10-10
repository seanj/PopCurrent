require File.dirname(__FILE__) + '/test_helper'


if $WITH_FERRET

class FerretIndexerTest < Test::Unit::TestCase
  fixtures :pages, :page_authors, :page_paras
 
  def setup
    @index_path = '/tmp/activesearch_test.idx'
    File.unlink(@index_path) if File.exist?(@index_path)
    setup_index
  end
 
  def teardown
    File.unlink(@index_path) if File.exist?(@index_path)
    ActiveSearch.indexers(Page.to_s).clear
    load File.dirname(__FILE__) + '/fixtures/page.rb'
  end
 
  def test_indexer_setup
    assert File.directory?('/tmp'), "/tmp must be a dir to run this test"
    assert File.writable?('/tmp'), "/tmp must be writable to run this test"    

    assert_equal 5, Page.indexers.size
    assert_kind_of Ferret::Index::Index, @indexer.ferret_index

		assert_equal 2, @indexer.size, "Indexer#size should be forwarded to Ferret underneath"
  end

	def test_pruning
		assert_equal 2, @indexer.size
    Page.indexers.last.prune!
		assert_equal 0, @indexer.size
  end

	def test_search
		assert_equal 2, @indexer.query('commonterm').size
    assert_equal 1, @indexer.query('brazil').size
		assert_equal 1, @indexer.query('julian').size

		assert_kind_of ActiveSearch::Result, Page.indexers.last.query('brazil').last

		assert_equal Page.find(1), @indexer.query('brazil')[0].record
		assert_equal Page.find(2), @indexer.query('veenman')[0].record
		
		Object.send(:remove_const, :Page)
		load File.dirname(__FILE__) + '/fixtures/page.rb'
		assert_equal 2, @indexer.query('commonterm').size
    assert_equal 1, @indexer.query('brazil').size
		assert_equal 1, @indexer.query('julian').size		
  end

  def test_index_updated
		setup_index
    page = Page.find(1)
    page.page_author = nil
    page.page_paras.clear
    page.body = "The pleasure of the discontent"
    page.save!

    assert_equal 1, @indexer.query("discontent").size      
    assert_equal page, @indexer.query("discontent")[0].record      
  end
 
  private
    def setup_index
      assert_nothing_raised do
        Page.class_eval do
          indexes_columns :into=>@index_path, :using=>:ferret
        end
      end
      @indexer = Page.indexers.last
      @indexer.rebuild!
    end
end

end