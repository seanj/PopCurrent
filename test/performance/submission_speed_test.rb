#---
# Excerpted from "Agile Web Development with Rails, 2nd Ed."
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/rails2 for more book information.
#---
require File.dirname(__FILE__) + '/../test_helper'
require 'submissions_controller'

# Re-raise errors caught by the controller.
class SubmissionController; def rescue_action(e) raise e end; end

class SubmissonSpeedTest < Test::Unit::TestCase
  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_100_submissions
    Submission.delete_all
    elapsed_time = Benchmark.realtime do
      100.downto(1) do |sub_id|
        assert submission = Submission.create(:title => sub_id.to_s, 
        :description => 'yyy', 
        :url => 'http://123.com/' + sub_id.to_s + '.mpg',
        :user_name => 'Fred',
        :user_id => 1)
        assert submission.tag_with('dog, cat, "fred flintsone", zoo')
      end       
    end       
    assert_equal 100, Submission.count 
    #assert elapsed_time < 3.00  
  end
end
