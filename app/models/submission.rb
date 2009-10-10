class Submission < ActiveRecord::Base
  belongs_to :user
  has_many :sub_pops
  has_many :sub_flops
  has_many :sub_blips
  has_many :comments, :order => "created_at DESC"
  
  file_column :image_url, :magick => { :versions => { "normal" => "48x48", "large" => "96x96" } }
  acts_as_taggable
  acts_as_urlnameable :title, :mode => :multiple
  
  indexes_columns :title, :description, :using=>:term

  validates_presence_of :title, :description, :url
  validates_uniqueness_of :title, :url
  validates_format_of :url, :with => /^http\:\/\//, :message => ": needs to begin with 'http://'."
  validates_exclusion_of :category, :in => '--Choose--', :message => ": please choose a category for your entry."
  
  validates_format_of :rss_url, :with => /^http\:\/\//, :message => ": needs to begin with 'http://'.", :if => Proc.new{|submission| !submission.rss_url.blank?}
  
  validates_format_of :itunes_url, :with => /^http\:\/\/phobos.apple.com/, :message => ": needs to begin with 'http://phobos.apple.com'.", :if => Proc.new{|submission| !submission.itunes_url.blank?}
  
  validates_format_of :torrent_url, :with => /^http\:\/\//, :message => ": needs to begin with 'http://'.", :if => Proc.new{|submission| !submission.torrent_url.blank?}
  validates_format_of :magnet_url, :with => /^magnet\:/, :message => ": needs to begin with 'magnet:'." , :if => Proc.new{|submission| !submission.magnet_url.blank?}
  
  validates_file_format_of :image_url, :in => ["gif", "png", "jpg"]
  #validates_filesize_of :image_url, :in => 0.kilobytes..128.kilobytes

  validates_no_profanity :title, :description

  validates_length_of :title, :url, :rss_url, :torrent_url, :magnet_url, :maximum => 255 
  validates_length_of :description, :maximum => 4000 

end
