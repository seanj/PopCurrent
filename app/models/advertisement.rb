class Advertisement < ActiveRecord::Base
  validates_presence_of :desc, :priority, :placement, :width, :height, :codeblock, :start_at, :expire_at
  validates_uniqueness_of :desc
  validates_length_of :desc, :placement,  :maximum => 255 
  validates_length_of :width, :height,  :maximum => 8 
  validates_length_of :codeblock, :maximum => 64000 
end
