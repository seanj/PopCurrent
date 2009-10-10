desc 'Create the default categories'
task :create_categories  => :environment do
  puts "Creating default categories"
  c = Category.new
  c.category_name = "Talk Shows"
  c.save
  
  c = Category.new
  c.category_name = "Videos"
  c.save
  
  c = Category.new
  c.category_name = "Music"
  c.save
  
  c = Category.new
  c.category_name = "Images"
  c.save
  
  c = Category.new
  c.category_name = "Games"
  c.save
end
