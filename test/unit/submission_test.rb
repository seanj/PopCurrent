require File.dirname(__FILE__) + '/../test_helper'

class SubmissionTest < Test::Unit::TestCase
  fixtures :submissions

  # Replace this with your real tests.
  def test_invalid_with_empty_attributes 
    submission = Submission.new 
    assert !submission.valid? 
    assert submission.errors.invalid?(:title) 
    assert submission.errors.invalid?(:description) 
    assert submission.errors.invalid?(:url)
  end
  
  def test_unique_title 
    submission = Submission.new(:title => submissions(:first).title, 
    :description => 'yyy', 
    :url => 'http://123.com/123.mpg')
    assert !submission.save 
    assert_equal "has already been taken", submission.errors.on(:title) 
  end 
  
 def test_invalid_url
   submission = Submission.new(:title => 'y0', 
   :description => 'yyy', 
   :url => '123.com/123.mpg',
   :rss_url => '123.com/123.mpg')
   assert !submission.save
   assert_equal "needs to begin with 'http://'.", submission.errors.on(:url) 
 end
 
 def test_invalid_rss_url
   submission = Submission.new(:title => 'y0', 
   :description => 'yyy', 
   :url => '123.com/123.mpg',
   :rss_url => '123.com/123.mpg')
   assert !submission.save
   assert_equal "needs to begin with 'http://'.", submission.errors.on(:rss_url) 
 end
 
 def test_invalid_magnet_url
   submission = Submission.new(:title => 'y0', 
   :description => 'yyy', 
   :url => '123.com/123.mpg',
   :magnet_url => '123.com/123.mpg')
   assert !submission.save
   assert_equal "needs to begin with 'magnet:'.", submission.errors.on(:magnet_url) 
 end
end
