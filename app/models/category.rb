class Category < ActiveRecord::Base

validates_length_of :category_name, :maximum => 30 

end
