class Profile < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :users
  has_many :profile_pops
  has_many :profile_flops
  
  file_column :image_url, :magick => {:versions => { "thumb" => "16x16", "small" => "24x24", "normal" => "48x48", "large" => "96x96" }}
  
  validates_file_format_of :image_url, :in => ["gif", "png", "jpg"]

  validates_length_of :description, :maximum => 4000 

end
