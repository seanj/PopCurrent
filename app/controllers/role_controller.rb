#***************************************************************
# Filename:       permission_controller.rb
# Authors:        Sean Jackson, Ray Slakinski
# Created:        April 2006
#
# Actions to manage Users
#
# Copyright 2006 popcurrent.com. All rights reserved.
#***************************************************************
class RoleController < ApplicationController
  layout "standard_adside"

  # We shouldn't accept GET requests that modify data.
  verify :method => :post, :only => %w(destroy)
  

  def index
    redirect_to :action => 'list'
  end


  def list
    @content_columns = Role.content_columns
    @role_pages, @roles = paginate :role, :per_page => 10
  end


  def show
    if (@role = find_role(params[:id]))
      @content_columns = Role.content_columns
        
      @all_permissions = @role.permissions

      # split it up into controllers
      @all_actions = {}
      @all_permissions.each { |permission|
        @all_actions[permission.controller] ||= []
        @all_actions[permission.controller] << permission
      }
    else
      redirect_back_or_default :action => 'list'
    end
  end


  def new
    case request.method
      when :get
        @role = Role.new
      when :post
        @role = Role.new(params[:role])
        if @role.save
          flash[:notice] = 'Role was successfully created.'
          redirect_to :action => 'list'
        else
          render_action 'new'
        end      
    end
  end
  

  def edit
    case request.method
      when :get
        if (@role = find_role(params[:id]))
          # load up the controllers
          @all_permissions = Permission.find_all
    
          # split it up into controllers
          @all_actions = {}
          @all_permissions.each { |permission|
            @all_actions[permission.controller] ||= []
            @all_actions[permission.controller] << permission
          }
        else
          redirect_back_or_default :action => 'list'
        end
      when :post
        if (@role = find_role(params[:id]))
          # update the action permissions
          permission_keys = params.keys.select { |k| k =~ /^permissions_/ }
          permissions = permission_keys.collect { |k| params[k] }
          
          begin
            permissions.collect! { |perm_id| Permission.find(perm_id) }
    
            # just wipe them all and re-build
            @role.permissions.clear
    
            permissions.each { |perm|
              if !@role.permissions.include?(perm)
                @role.permissions << perm
              end
            }
            
            # save the object    
            if @role.update_attributes(params[:role])
              flash[:notice] = 'Role was successfully updated.'
              redirect_to :action => 'show', :id => @role
            else
              flash[:message] = 'The role could not be updated.'
              render :action => 'edit'
            end
          rescue ActiveRecord::RecordNotFound => e
            flash[:message] = 'Permission not found!'
            render :action => 'edit'
          end
        else
          redirect_back_or_default :action => 'list'
        end       
    end        
  end


  def destroy
    if (@role = find_role(params[:id]))
      begin
        @role.destroy
        flash[:notice] = "Role '#{@role.name}' has been deleted." 
        redirect_to :action => 'list'
      rescue UserEngine::SystemProtectionError => e
        flash[:message] = "Cannot destroy the system role '#{@role.name}'!"
        redirect_to :action => 'list'
      end
    else
      redirect_back_or_default :action => 'list'
    end
  end
  

  protected
    def find_role(id)
      begin
        Role.find(id)
      rescue ActiveRecord::RecordNotFound
        flash[:message] = "There is no role with ID ##{id}"
        nil
      end
    end     
end
