require File.dirname(__FILE__) + '/test_helper'

class BaseIndexerTest < Test::Unit::TestCase
  fixtures :pages, :page_authors, :page_paras

  def setup
		@ferret = ($WITH_FERRET ? 0 : 1)
    @idxr = ActiveSearch::Indexer.new(Page)
    @idxr.setup_with_options({})
  end
  
  def test_term_to_array
    assert_equal ['foo'], @idxr.send(:term_to_array, 'foo ')
    assert_equal ['foo', 'bla'], @idxr.send(:term_to_array, 'foo AND bla')

    assert_equal ['foo', 'bar', 'baz', 'form'], @idxr.send(:term_to_array, 'foo AND bar OR baz OR form')
  end
end