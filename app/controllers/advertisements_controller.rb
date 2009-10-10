#********************************************************
# Filename:       submissions_controller.rb
# Authors:        Sean Jackson, Ray Slakinski
# Created:        April 2006
#
# Actions to manage Submissions
#
# Copyright 2006 popcurrent.com. All rights reserved.
#********************************************************
class AdvertisementsController < ApplicationController
  before_filter :login_required, :only => [:index, :list, :new, :create, :edit, :update, :destroy]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }


  def index
    @session[:current_page] = $page_admanager  
    list
    render :action => 'list'
  end


  def list
    @session[:current_page] = $page_admanager  
    if((authorized?(:controller => "user", :action => "edit_roles")))
       @advertisement_pages, @advertisements = paginate(:advertisements, 
                                                        :per_page => 10, 
                                                        :order => 'placement desc, priority, start_at')
       render(:layout => 'forms')
    else
      redirect_to(:controller => 'submissions', :action => 'frontpage_list')
    end
  end


  def show
    @advertisement = Advertisement.find(:first, 
                                        :conditions => "placement ='" + @params[:placement] + 
                                        "' AND enabled = 1" + " AND (start_at < Now() AND expire_at > Now())",
                                        :order => 'priority, rand()')
                                          
    @placement = @params[:placement]
    render(:layout => false)
  end


  def new
    @session[:current_page] = $page_admanager  
    if((authorized?(:controller => "user", :action => "edit_roles")))
      @advertisement = Advertisement.new
      render(:layout => 'forms')
    else
      redirect_to(:controller => 'submissions', :action => 'frontpage_list')
    end
  end


  def create
    @session[:current_page] = $page_admanager  
    if((authorized?(:controller => "user", :action => "edit_roles")))
      @advertisement = Advertisement.new(params[:advertisement])
      if @advertisement.save
        flash[:notice] = 'Advertisement was successfully created.'
        redirect_to :action => 'list'
      else
        render(:action => 'new', :layout => 'standard_adside')
      end
    else
      redirect_to(:controller => 'submissions', :action => 'frontpage_list')
    end
  end


  def edit
    @session[:current_page] = $page_admanager  
    if((authorized?(:controller => "user", :action => "edit_roles")))
      @advertisement = Advertisement.find(params[:id])
      render(:layout => 'forms')
    else
      redirect_to(:controller => 'submissions', :action => 'frontpage_list')
    end
  end


  def update
    @session[:current_page] = $page_admanager  
    if((authorized?(:controller => "user", :action => "edit_roles")))
      @advertisement = Advertisement.find(params[:id])
      if @advertisement.update_attributes(params[:advertisement])
        flash[:notice] = 'Advertisement was successfully updated.'
        redirect_to :action => 'list'
      else
        render(:action => 'edit', :layout => 'forms')
      end
    else
      redirect_to(:controller => 'submissions', :action => 'frontpage_list')
    end
  end


  def destroy
    @session[:current_page] = $page_admanager  
    if((authorized?(:controller => "user", :action => "edit_roles")))
      Advertisement.find(params[:id]).destroy
      redirect_to :action => 'list'
    else
      redirect_to(:controller => 'submissions', :action => 'frontpage_list')
    end
  end
end
