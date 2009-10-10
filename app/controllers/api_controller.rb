#*********************************************************
#  Filename:       api_conrtoller.rb
#  Authors:        Ray Slakinski, Sean Jackson
#  Created:        May 2006
#
#  Copyright 2006 popcurrent.com. All rights reserved.
#*********************************************************
class ApiController < ApplicationController
  before_filter :login_required, :except => [:entries, :entrypromo, :userpromo, 
                                             :user_pops, :user_flops, :podcastpromo]

  def entries 
    if params[:urlname]
      @submission = Submission.find_by_urlname(params[:urlname])
      @submissions = [@submission]
    else
      @submissions = Submission.find(:all, :limit => 40, :order => "created_at desc")
    end
    render(:layout => false)
  end

  
  def entrypromo
    @submission = Submission.find_by_urlname(params[:urlname])
    render(:layout => false)
  end

  
  def podcastpromo
    @submission = Submission.find_by_rss_url(params[:rssurl], :limit => 1, :order => "created_at desc")
    render(:action => "entrypromo", :layout => false)
  end

  def user_pops
    if params[:user]
      @user = User.find_by_login(params[:user])
      @submissions = Submission.find(:all, :include => 'sub_pops', 
                                     :conditions =>["sub_pops.user_id = ?",@user.id], 
                                     :order => "sub_pops.created_at desc", 
                                     :limit => 10)
    else
      @submissions = Submission.find(:all, :order => "created_at desc", :limit => 10)
    end
    render(:layout => false)
  end


  def user_flops
    if params[:user]
      @user = User.find_by_login(params[:user])
      @submissions = Submission.find(:all, :include => 'sub_flops', 
                                     :conditions =>["sub_pops.user_id = ?",@user.id], 
                                     :order => "sub_flops.created_at desc", 
                                     :limit => 10)
    else
      @submissions = Submission.find(:all, :order => "created_at desc", :limit => 10)
    end
    render(:layout => false)
  end
end