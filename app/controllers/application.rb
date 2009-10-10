#*********************************************************
#  Filename:       application.rb
#  Authors:        Sean Jackson, Ray Slakinski
#  Created:        April 2006
#
#  Filters added to this controller will be run for all
#  controllers in the application.
#  
#  Likewise, all the methods added will be available 
#  for all controllers.
#
#  Copyright 2006 popcurrent.com. All rights reserved.
#*********************************************************
require 'login_engine'

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  
  before_filter :set_charset, :login_from_cookie
  
  
  layout "standard"
  
  include LoginEngine
  include UserEngine
  
  helper :user
  model :user
  
  #Global Variables
  #values for :current_page used app wide
  $page_hotnow               = 1
  $page_newestentries        = 2
  $page_bestentries          = 3
  $page_critics              = 4
  $page_submit               = 5
  $page_whatispopcurrent     = 6
  $page_poppedbyfriends      = 7
  $page_floppedbyfriends     = 8
  $page_submittedbyfriends   = 9
  $page_commentedbyfriends   = 10
  $page_tagresults           = 11
  $page_searchresults        = 12
  $page_profile              = 13
  $page_usersearchresults    = 14
  $page_admanager            = 15
  $page_other                = 16
  $page_single_entry         = 17  
  $page_editprofile          = 18
  $page_invite               = 19
  $page_signup               = 20
  $page_terms                = 21
  $page_privacy              = 22
  $page_forgotpwd            = 23
  
  #Email templates
  $invite_subject           = "You have been invited to discover popcurrent.com!"
  
  $invite_body              = "This email has been sent to you from a friend as an invitation to discover some of the best and most popular media available online." + 
                            "<br /><br />At popcurrent.com, you can easily find thousands of links to podcasts, music, videos, images and online books, the best of which are voted up in " + 
  		                      "popularity by people just like you!  You are the critic. <br /><br />So browse over to http://www.popcurrent.com to start enjoying all the " +
  		                      "great media right now and remember to signup for a free account and start voting for your favorites.<br /><br />"

  $pop_subject           = "You have been invited to vote for an entry at popcurrent.com!"

  $pop_body              = "Hello, you have been asked to visit popcurrent.com and Pop (vote for) the following entry:" +
                            "<br /><br />Title: <i>[title of entry]</i><br /><br /" +
                            "<br />Description: <i>[description of entry]</i><br />" +
                            "<br />Link: <i>[link to entry]</i><br />" +
                            "<br />Click the link above to Pop this entry.  Popping an entry will help to move it up in the rankings at popcurrent and help it gain more exposure on the site." +
                            "<br /><br />At popcurrent.com, you can easily find thousands of links to podcasts, music, videos, images and online books, the best of which are voted up in " + 
  		                      "popularity by people just like you!  You are the critic."
  
  #What Is PopCurrent page
  def whatIsPopCurrent
    @session[:current_page] = $page_whatispopcurrent

    if(request.xhr?)
      render(:layout => false)
    else
      render(:layout => "standard_adside")
    end
  end


  #Terms of Service page
  def tos
    @session[:current_page] = $page_terms
    
    if(request.xhr?)
      render(:layout => false)
    else
      render(:layout => "standard_adside")
    end
  end


  #Privacy Policy page
  def privacy
    @session[:current_page] = $page_privacy
    
    if(request.xhr?)
      render(:layout => false)
    else
      render(:layout => "standard_adside")
    end
  end


  def set_charset
    @headers["Content-Type"] = "text/html; charset=utf-8" 
  end


  def login_from_cookie
    return unless cookies[:auth_token] && @session[:user].nil?
    user = User.find_by_remember_token(cookies[:auth_token]) 
    if user && !user.remember_token_expires.nil? && Time.now < user.remember_token_expires 
      @session[:user] = user
    end
  end

  
  def opml_directory
    render_without_layout
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  def header
    @submission = Submission.find(params[:id]) if(!params[:id].nil?)
    render(:layout => false)
  end
  
  def memberlinks
    render(:layout => false)
  end
  
  def invite_form 
    @session[:current_page] = $page_invite

    case request.method
      when :post
        @addresses = @params[:email][:emailaddresses]
        @message = @params[:email][:emailmessage]
        if(@addresses.length > 1)
          
          @valid_addresses = @addresses.split(",")
          for @valid_address in @valid_addresses
            if(!valid_email(@valid_address))
              flash[:warning] = 'You have entered an invalid email address near "' + @valid_address + "'."
              render(:layout => "forms")
              return
            end
          end
          
          @mailer = InviteMailer.deliver_invite(@addresses, @message)
          #render(:text => "<pre>" + @mailer.encoded + "</pre>")
          
          flash[:notice] = 'Your email was sent sucessfully!'
        else
          flash[:warning] = 'Could not send email due to blank or invalid email addresses.'
        end
    end

    if(request.xhr?)
      render(:layout => false)
    else
      render(:layout => "forms")
    end
  end
  
  def valid_email(email)
    apos=email.index('@').to_i 
    dotpos=email.rindex(".")
    lastpos=email.length-1;
    if (apos < 3 || lastpos-dotpos<2) 
      return false
    end
    return true
  end
  
  def activity
    render(:layout => false)
  end
  
end

