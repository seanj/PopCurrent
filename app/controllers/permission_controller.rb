#***************************************************************
# Filename:       permission_controller.rb
# Authors:        Sean Jackson, Ray Slakinski
# Created:        April 2006
#
# Actions to manage Users
#
# Copyright 2006 PopCurrent.com. All rights reserved.
#***************************************************************
class PermissionController < ApplicationController
  layout "standard_adside"
  
  # We shouldn't accept GET requests that modify data.
  verify :method => :post, :only => %w(destroy)


  def index
    redirect_to :action => "list"
  end


  def list
    @content_columns = Permission.content_columns
    @permission_pages, @permissions = paginate :permission, :order => 'id', :per_page => 15
  end


  def show
    if (@permission = find_permission(params[:id]))
      @content_columns = Permission.content_columns
    else
      redirect_back_or_default :action => 'list'
    end    
  end


  def new
    case request.method
      when :get
        @permission = Permission.new
      when :post
        @permission = Permission.new(@params[:permission])
        if @permission.save
          flash[:notice] = 'Permission was successfully created.'
          redirect_to :action => 'list'
        else
          render_action 'new'
        end      
    end
  end


  def edit
    case request.method
      when :get
        if (@permission = find_permission(params[:id])).nil?
          redirect_back_or_default :action => 'list'
        end
      when :post
        if (@permission = find_permission(params[:id]))
          if @permission.update_attributes(@params[:permission])
            flash[:notice] = 'Permission was successfully updated.'
            redirect_to :action => 'show', :id => @permission
          else
            render_action 'edit'
          end
        else
          redirect_back_or_default :action => 'list'
        end              
    end
  end


  def destroy
    if (@permission = find_permission(params[:id]))
      @permission.destroy
      flash[:notice] = "Permission '#{@permission.path}' deleted."
      redirect_to :action => 'list'
    else
      redirect_back_or_default :action => 'list'
    end
  end
  
  
  protected
    def find_permission(id)
      begin
        Permission.find(id)
      rescue
        flash[:message] = "There is no permission with ID ##{id}"
        nil
      end
    end
end
