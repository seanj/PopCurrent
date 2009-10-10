require File.dirname(__FILE__) + '/test_helper'

class LikeIndexerTest < Test::Unit::TestCase
  fixtures :pages, :page_authors, :page_paras

  def setup
    Page.indexers[0].rebuild!
    Page.indexers[2].rebuild!
    
    PageAuthor.indexers[0].rebuild!
    
    @page_like_indexer = Page.indexers[0]
    @page_like_indexer_with_conditional = Page.indexers[2]
    
    @page_author_like_indexer = PageAuthor.indexers[0]
  end

  def test_searches
    
    assert_kind_of ActiveSearch::LikeIndexer, @page_like_indexer
    assert_kind_of ActiveSearch::LikeIndexer, @page_author_like_indexer
    assert_kind_of ActiveSearch::LikeIndexer, @page_like_indexer_with_conditional

    @unapproved_page = Page.find(1)
    @approved_page = Page.find(2)
    
    assert @page_like_indexer_with_conditional.will_consume_record?(@approved_page)
    assert !@page_like_indexer_with_conditional.will_consume_record?(@unapproved_page)
    
    assert_nil @page_like_indexer.creation_options[:if]  
    assert_equal :approved?, @page_like_indexer_with_conditional.creation_options[:if]
    
    assert_equal [Page.find(1)], @page_like_indexer.query("brazil")
      "The first page should be found"

    assert_equal [Page.find(2)], @page_like_indexer.query("japanese"),
      "Related paras should be included in the search"
    
    assert_equal [Page.find(2)], @page_like_indexer.query("veenman"),
      "Related authors should be included in the search"

    assert_equal [Page.find(2)], @page_like_indexer.query("approved"),
      "Record that is 'Approved' should be found by predicate"

    assert_equal [PageAuthor.find(1)], @page_author_like_indexer.query("JuliAn"),
      "Searches should be case-insensitive"
      
    assert_equal [PageAuthor.find(1)], @page_author_like_indexer.query("Julian Tarkhanov"),
      "Author should be included in the index"

    assert_equal [PageAuthor.find(2)], @page_author_like_indexer.query("Tuesday"),
      "Record that was modified on Tuesday should be found"

    assert_equal 1, @page_like_indexer_with_conditional.query("something").length,
      "Only the page that was 'Approved' should get indexed"

    assert_equal Page.find(2).id, @page_like_indexer_with_conditional.query("something").first.id,
      "Only the page that was 'Approved' should get indexed"
  end
  
  def test_create
    @page = Page.create(:page_author_id => 1,
        :title => "Welcome to Honduras",
        :body => "Honduras is a beautiful country")
    
    assert_equal [@page], @page_like_indexer.query("honduras")
  end

	def test_scoped_search
		assert_equal 2, @page_like_indexer.query('commonterm').size
		
		Page.with_scope(:find => {:conditions => 'page_author_id = 1'}) do
			found_pages = @page_like_indexer.query('commonterm')
			assert_equal 1, found_pages.length
			assert_equal [Page.find(1)], found_pages
		end
	end
  
  def test_pruning
    @page_like_indexer.prune!
    assert_equal [], @page_author_like_indexer.query("japanese")    
  end
  
  def test_delete
    Page.destroy_all
    assert_equal [], @page_author_like_indexer.query("galaxy")
  end
  
  def test_index_updated
    page = Page.find(1)
    page.page_author = nil
    page.page_paras.clear
    page.body = "The pleasure of the discontent"
    page.save!

    assert_equal [], @page_like_indexer.query("galaxy")    
    assert_equal [page], @page_like_indexer.query("discontent")      
  end
end