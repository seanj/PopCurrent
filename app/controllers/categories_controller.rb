#*********************************************************
# Filename:       categories_controller.rb
# Authors:        Sean Jackson, Ray Slakinski
# Created:        April 2006
#
# Actions to manage global Categories in Administration Mode
#
# Copyright 2006 popcurrent.com. All rights reserved.
#*********************************************************
class CategoriesController < ApplicationController
  before_filter :login_required
  layout "standard_adside"
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }


  def index
    list
    render :action => 'list'
  end


  def list
    @category_pages, @categories = paginate :categories, :per_page => 10
  end


  def show
    @category = Category.find(params[:id])
  end


  def new
    @category = Category.new
  end


  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = 'Category was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end


  def edit
    @category = Category.find(params[:id])
  end


  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      flash[:notice] = 'Category was successfully updated.'
      redirect_to :action => 'show', :id => @category
    else
      render :action => 'edit'
    end
  end


  def destroy
    Category.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
