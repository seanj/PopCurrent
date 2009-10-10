class CreateIndexes < ActiveRecord::Migration
  def self.up
    add_index :comments, :submission_id, :name => 'submission_id_idx'
    
    add_index :friends, :user_id, :name => 'user_id_idx'
    add_index :friends, :profile_id, :name => 'profile_id_idx'
    
    add_index :profile_flops, :user_id, :name => 'user_id_idx'
    add_index :profile_flops, :profile_id, :name => 'profile_id_idx'
    
    add_index :profile_pops, :user_id, :name => 'user_id_idx'
    add_index :profile_pops, :profile_id, :name => 'profile_id_idx'
    
    add_index :profiles, :user_id, :name => 'user_id_idx'
    
    add_index :search_terms_submissions, :search_term_id, :name => 'search_term_id_idx'
    add_index :search_terms_submissions, :submission_id, :name => 'submission_id_idx'
    
    add_index :search_terms_users, :search_term_id, :name => 'search_term_id_idx'
    add_index :search_terms_users, :user_id, :name => 'user_id_idx'
    
    add_index :sub_blips, :user_id, :name => 'user_id_idx'
    add_index :sub_blips, :submission_id, :name => 'submission_id_idx'
    
    add_index :sub_pops, :user_id, :name => 'user_id_idx'
    add_index :sub_pops, :submission_id, :name => 'submission_id_idx'

    add_index :sub_flops, :user_id, :name => 'user_id_idx'
    add_index :sub_flops, :submission_id, :name => 'submission_id_idx'
 
    add_index :taggings, :tag_id, :name => 'tag_id_idx'
    add_index :taggings, :taggable_id, :name => 'taggable_id_idx'
    
    add_index :urlnames, :nameable_id, :name => 'nameable_id_idx'
  end
end
