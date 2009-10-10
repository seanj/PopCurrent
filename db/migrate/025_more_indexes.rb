class MoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :profiles, :vote_total, :name => 'vote_total_idx'    
    
    add_index :permissions_roles, :permission_id, :name => 'permission_id_idx'
    add_index :permissions_roles, :role_id, :name => 'role_id_idx'
    
    add_index :submissions, :user_id, :name => 'user_id_idx'  
    add_index :submissions, :vote_total, :name => 'vote_total_idx'    
    add_index :submissions, :category, :name => 'category_idx'    
    
    add_index :taggings, :taggable_type, :name => 'taggable_type_idx' 
    
    add_index :urlnames, :nameable_type, :name => 'nameable_type_idx'    
  end
end
