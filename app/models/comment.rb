class Comment < ActiveRecord::Base
  acts_as_threaded
  belongs_to :submission
  
  validates_presence_of :body
  
  validates_no_profanity :subject, :body

  validates_length_of :subject, :maximum => 255 
  validates_length_of :body, :maximum => 4000 

end
