#*********************************************************
# Filename:       submissions_controller.rb
# Authors:        Sean Jackson, Ray Slakinski
# Created:        April 2006
#
# Actions to manage Users
#
# Copyright 2006 popcurrent.com. All rights reserved.
#*********************************************************
class UserController < ApplicationController
  model   :user
  layout  "forms"
  
  def home
    if user?
      @fullname = "#{current_user.firstname} #{current_user.lastname}"
    else
      @fullname = "Not logged in..."
    end 
    
    redirect_to_stored_or_default(:controller => 'submissions', :action => 'frontpage_list')
  end


  def profile
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_profile

    @content_columns = user_content_columns_to_display    
    @user = User.find_by_login(params[:user])
    if !@user
      redirect_to :controller => 'user', :action => 'list'
      return
    end
    
    if(request.xhr?)  
      render(:layout => false)
    else
      render(:layout => "standard_adside")
    end
    
  end


  def profile_pop_it
    @user = User.find(params[:id])
    if(request.xhr?)
      if @user.profile.profile_pops.find_by_user_id(session[:user].id) == nil and @user.profile.profile_flops.find_by_user_id(session[:user].id) == nil
        @user.profile.profile_pops << ProfilePop.new(:user_id => session[:user].id, :created_at => Time.now)
        @user.profile.vote_total = @user.profile.vote_total + 1
        @user.save
      end
      render( :layout => false )
    else
      redirect_to_stored_or_default(:action => 'profile')
    end
  end


  def profile_un_pop
    @user = User.find(params[:id])
    if(request.xhr?)
      @pop = @user.profile.profile_pops.find_by_user_id(session[:user].id)
    
      if @pop != nil
        @pop.destroy()
        @user.profile.vote_total = @user.profile.vote_total - 1
        @user.save
      end
      render( :layout => false )
    else
      redirect_to_stored_or_default(:action => 'profile')
    end
  end


  def profile_flop_it
    @user = User.find(params[:id])
    if(request.xhr?)
      
      if !authorized?(:controller => "user", :action => "edit_roles")
        date = Time.now - 1.day
        @total_flops = ProfileFlop.find(:all,
                                    :conditions => ["user_id = " + String(session[:user].id) + " AND created_at > ?", date])

        if(!@total_flops.nil? && @total_flops.length >= 3)
          flash[:success] = 'toomanyflops'
          render( :layout => false )
          return
        end
      end
      
      if @user.profile.profile_pops.find_by_user_id(session[:user].id) == nil and @user.profile.profile_flops.find_by_user_id(session[:user].id) == nil and @session[:user].profile.vote_total >= 0
        @user.profile.profile_flops << ProfileFlop.new(:user_id => session[:user].id, :created_at => Time.now)
        @user.profile.vote_total = @user.profile.vote_total - 1
        @user.save
      end
      render( :layout => false )
    else
      redirect_to_stored_or_default(:action => 'profile')
    end
  end


  def profile_un_flop
    @user = User.find(params[:id])
    if(request.xhr?)
      @flop = @user.profile.profile_flops.find_by_user_id(session[:user].id)
    
      if @flop != nil
        @flop.destroy()
        @user.profile.vote_total = @user.profile.vote_total + 1
        @user.save
      end
      render( :layout => false )
    else
      redirect_to_stored_or_default(:action => 'profile')
    end
  end


  def add_friend
    if(current_user)
      @user =  User.find(params[:id])
      for friend in current_user.friends
    	  is_friend = true if(friend.profile_id == @user.profile.id)
      end
      if(!is_friend)
        current_user.friends << Friend.new(:profile_id => @user.profile.id)
        current_user.save
      end
      
      showFull = false
      if(params[:bShowFull] == "true")
        showFull = true
      end
        
      render(:partial => "profile", :object => @user, :locals => {:bShowFull => showFull})
    else
      redirect_to_stored_or_default(:controller => 'submissions', :action => 'frontpage_list')
    end
  end
  

  def remove_friend
    if(current_user)
      @user =  User.find(params[:id])
      deleteFriend = current_user.friends.find(:first, :conditions => ["user_id = ? AND profile_id = ?", current_user.id, @user.profile.id])
      current_user.friends.delete_if{|n| n.id == deleteFriend.id}
      deleteFriend.destroy

      showFull = false
      if(params[:bShowFull] == "true")
        showFull = true
      end

      render(:partial => "profile", :object => @user, :locals => {:bShowFull => showFull})
    else
      redirect_to_stored_or_default(:controller => 'submissions', :action => 'frontpage_list')
    end
  end


  def show_friends
    @user = User.find(params[:id])
    @sub_user_pages, @sub_users = paginate(:friends,
                                         :conditions => ["friends.user_id = ?",@user.id],
                                         :select => "profile_id",
                                         :per_page => 25)
    render( :layout => false )
  end

  
  def login
    #To set current page for tabs in _header.rhtml
   
    case request.method
    when :get
      redirect_to(:controller => 'submissions', :action => 'frontpage_list')
      return 
    when :post
      if(params[:user])
        @user = User.new(params[:user])
        @login = params[:user][:login]
        if session[:user] = User.authenticate(params[:user][:login], params[:user][:password])
          session[:user].logged_in_at = Time.now
          session[:user].save
          flash[:notice] = 'Login successful'

          if @params[:save_login] == "on"
            @session[:user].remember_me
            cookies[:auth_token] = { :value => @session[:user].remember_token , :expires => @session[:user].remember_token_expires }
          end

        else
          flash.now[:warning] = 'Login unsuccessful'
        end

        if(request.xhr?)
          render(:layout => false)
        else
          redirect_to_stored_or_default(:controller => 'submissions', :action => 'frontpage_list')
        end
      else
        render(:layout => false)
      end
    end
  end


  def signup
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_signup
    
    case request.method
      when :get
        @user = User.new
        render (:layout => "forms")
        return true
      
      when :post
        if(request.xhr?)
          @user = User.new
          render (:layout => false)
          return true
        end
        
        params[:user].delete('form')
        @user = User.new(params[:user])
        @profile = Profile.new()
        @user.registered_from_ip = request.remote_ip
        begin
          User.transaction(@user) do
            @user.new_password = true
            unless LoginEngine.config(:use_email_notification) and LoginEngine.config(:confirm_account)
              @user.verified = 1
            end
            if @user.save
              @user.profile = @profile
              key = @user.generate_security_token
              url = url_for(:action => 'home', :user_id => @user.id, :key => key)
              flash[:notice] = 'Signup successful! Please log in.'
              if LoginEngine.config(:use_email_notification) and LoginEngine.config(:confirm_account)
                UserNotify.deliver_signup(@user, params[:user][:password], url)
                flash[:notice] << ' Please check your registered email account to verify your account registration and continue with the login.'
              end
              redirect_to(:action => 'signup2')
            end
          end
        rescue Exception => e
          flash[:success] = "failed"
          flash.now[:notice] = nil
          flash.now[:warning] = 'Error creating account: confirmation email not sent'
          logger.error "Unable to send confirmation E-Mail:"
          logger.error e
          render(:layout => "forms")
        end
    end
  end

  
  def signup2
  end

  
  def opml
    @user = User.find_by_login(params[:user])
    render_without_layout
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end
  
  def opml_critics_directory
    @critics = User.find(:all, :conditions=>'verified=1 and login != \'root\'')
    render_without_layout
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end
  
  def rss
    if params[:user]
      @user = User.find_by_login(params[:user])
      if params[:type]
        case params[:type]
        when "pop"
          @submissions = Submission.find(:all, :include => 'sub_pops', :conditions =>["sub_pops.user_id = ?",@user.id], :order => "updated_at desc", :limit => 40)
        when "flop"
          @submissions = Submission.find(:all, :include => 'sub_flops', :conditions =>["sub_flops.user_id = ?",@user.id], :order => "updated_at desc", :limit => 40)
        else
          @submissions = Submission.find(:all, :include => 'sub_pops', :conditions =>["sub_pops.user_id = ?",@user.id], :order => "updated_at desc", :limit => 40)
        end
      else
        params[:type] = "pop"
        @submissions = Submission.find(:all, :include => 'sub_pops', :conditions =>["sub_pops.user_id = ?",@user.id], :order => "updated_at desc", :limit => 40)
      end
    end
    
    render_without_layout
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  
  def search
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_usersearchresults
    @session[:items_per_page] = "10" if (!@session[:items_per_page])
    
    query = params[:query] || ''
    
    @user_pages, @all_users = paginate(:users,
                                       :select => "DISTINCT s.*",
                                       :joins => "AS s INNER JOIN search_terms_users ts ON s.id = ts.user_id INNER JOIN search_terms tg ON ts.search_term_id = tg.id",
                                       :per_page => Integer(@session[:items_per_page]), 
                                       :conditions => ["login != \'root\' AND tg.term like ?", "%" + query + "%"],
                                       :order => "s.created_at ASC")
       
    if(request.xhr?)  
      render(:action => "list", :layout => false)
    else
      render(:action => "list", :layout => "standard_adside")
    end
  end


  def logout
    @session[:user].forget_me if @session[:user]
    session[:user] = nil
    cookies.delete :auth_token
    redirect_to_stored_or_default(:controller => 'submissions', :action => 'frontpage_list')
  end


  def change_password
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_other

    return if generate_filled_in
    if do_change_password_for(@user)
      redirect_back_or_default(:action => 'edit_user')
    end
  end

  protected
    def do_change_password_for(user)
      begin
        User.transaction(user) do
          user.change_password(params[:user][:password], params[:user][:password_confirmation])
          if user.save
            if LoginEngine.config(:use_email_notification)
              UserNotify.deliver_change_password(user, params[:user][:password])
              flash[:notice] = "Updated password emailed to #{@user.email}"
            else
              flash[:notice] = "Password updated."
            end
            return true
          else
            flash[:warning] = 'There was a problem saving the password. Please retry.'
            return false
          end
        end
      rescue
        flash[:warning] = 'Password could not be changed at this time. Please retry.'
      end
    end
    
  public

  def forgot_password
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_forgotpwd


    if user?
      flash[:message] = 'You are currently logged in. You may change your password now.'
      redirect_to(:controller => "submissions", :action => 'frontpage_list')
      return
    end

    if !LoginEngine.config(:use_email_notification)
      flash[:message] = "Please contact the system admin at #{LoginEngine.config(:admin_email)} to reset your password."
      redirect_back_or_default(:action => 'login')
      return
    end

    return if generate_blank

    if params[:user][:email].empty?
      flash.now[:warning] = 'Please enter a valid email address.'
    elsif (user = User.find_by_email(params[:user][:email])).nil?
      flash.now[:warning] = "We could not find a user with the email address #{params[:user][:email]}"
    else
      begin
        User.transaction(user) do
          key = user.generate_security_token
          url = url_for(:action => 'change_password', :user_id => user.id, :key => key)
          UserNotify.deliver_forgot_password(user, url)
          flash[:notice] = "Instructions on resetting your password have been emailed to #{params[:user][:email]}"
        end  
        unless user?
          redirect_to(:action => 'login')
          return
        end
        redirect_back_or_default(:action => 'home')
      rescue
        flash.now[:warning] = "Your password could not be emailed to #{params[:user][:email]}"
      end
    end
  end


  def list
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_critics;
    
    if(@params[:critic_filter])
      @session[:critic_filter] = @params[:critic_filter]
    else
      @session[:critic_filter] = "popular"
    end

    if(@session[:critic_filter] == "popular")
      if authorized?(:controller => "user", :action => "edit_roles")
        @user_pages, @all_users = paginate :user, :per_page => 15, :conditions => 'login != \'root\'',:select => "us.*", :joins => "as us INNER JOIN profiles p ON p.user_id = us.id", :order => 'p.vote_total desc'        
      else
        @user_pages, @all_users = paginate :user, :per_page => 15, :conditions => 'login != \'root\' and verified > 0', :select => "us.*", :joins => "as us INNER JOIN profiles p ON p.user_id = us.id", :order => 'p.vote_total desc'        
      end
    else
      if authorized?(:controller => "user", :action => "edit_roles")
        @user_pages, @all_users = paginate :user, :per_page => 15, :conditions => 'login != \'root\'',:select => "us.*", :joins => "as us INNER JOIN profiles p ON p.user_id = us.id", :order => 'us.created_at desc'        
      else
        @user_pages, @all_users = paginate :user, :per_page => 15, :conditions => 'login != \'root\' and verified > 0', :select => "us.*", :joins => "as us INNER JOIN profiles p ON p.user_id = us.id", :order => 'us.created_at desc'        
      end
    end
    
    if(request.xhr?)  
      render(:layout => false)
    else
      render(:layout => "standard_adside")
    end
  end

  
  def edit_user
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_editprofile;

    if (@user = find_user(params[:id]))
      @all_roles = Role.find_all.select { |r| r.name != UserEngine.config(:guest_role_name) }
      case request.method
        when :get
          if(!@user.profile.nil?)
            @profile = @user.profile
            render(:layout => "forms")
          end
        when :post
          # setup profile details
          if(!@user.profile.nil?)
            @user.profile.attributes = params[:profile]
          else
            profile = Profile.new(params[:profile])
          end
          @user.attributes = params[:user].delete_if { |k,v| not LoginEngine.config(:changeable_fields).include?(k) }
          if @user.save
            if(@user.profile.nil?)
              @user.profile = profile
            end
            @profile = @user.profile
            @session[:user] = @user
            redirect_to ('/critics/' + @user.login)
            flash.now[:notice] = "Details for profile '#{@user.login}' have been successfully updated."
          else
            flash.now[:warning] = "Details could not be updated!"
          end
      end
    else
      redirect_back_or_default :action => 'list'
    end
  end
  

  def edit_roles
    if (@user = find_user(params[:id]))
      begin
        User.transaction(@user) do
        
          roles = params[:user][:roles].collect { |role_id| Role.find(role_id) }
          # add any new roles & remove any missing roles
          roles.each { |role| @user.roles << role if !@user.roles.include?(role) }
          @user.roles.each { |role| @user.roles.delete(role) if !roles.include?(role) }

          @user.save
          flash[:notice] = "Roles updated for user '#{@user.login}'."
        end
      rescue
        flash[:warning] = 'Roles could not be edited at this time. Please retry.'
      ensure
        redirect_to :back
      end
    else
      redirect_back_or_default :action => 'list'
    end
  end


  def edit
    if authorized?(:controller => "user", :action => "edit_roles")
      #To set current page for tabs in _header.rhtml
      @session[:current_page] = $page_other;

      return if generate_filled_in
      do_edit_user(@user)
    else
      redirect_back_or_default :action => 'list'
    end
  end

  
  def verify
    if authorized?(:controller => "user", :action => "delete_user")
      user = User.find(params[:id])
      user.verified = 1
      user.save
    end
    redirect_back_or_default :action => 'list'
  end


  def unverify
    if authorized?(:controller => "user", :action => "delete_user")
      user = User.find(params[:id])
      user.verified = 0
      user.save
    end
    redirect_back_or_default :action => 'list'
  end


  def delete
    if authorized?(:controller => "user", :action => "edit_roles")
      get_user_to_act_on
      if do_delete_user(@user)
        logout
      else
        redirect_back_or_default(:action => 'home')
      end    
    else
      redirect_back_or_default :action => 'list'
    end
  end
  

  def restore_deleted
    get_user_to_act_on
    @user.deleted = 0
    if not @user.save
      flash.now[:warning] = "The account for #{@user['login']} was not restored. Please try the link again."
      redirect_to(:action => 'login')
    else
      redirect_to(:action => 'home')
    end
  end


  protected
    def do_edit_user(user)
      begin
        User.transaction(user) do
          user.attributes = params[:user].delete_if { |k,v| not LoginEngine.config(:changeable_fields).include?(k) }
          if user.save
            flash[:notice] = "User details updated"
          else
            flash[:warning] = "Details could not be updated! Please retry."
          end
        end
      rescue
        flash.now[:warning] = "Error updating user details. Please try again later."
      end
    end


    def find_user(id)
      begin
        User.find(id)
      rescue ActiveRecord::RecordNotFound
        flash[:message] = "There is no user with ID ##{id}"
        nil
      end
    end


    def destroy(user)
      UserNotify.deliver_delete(user) if LoginEngine.config(:use_email_notification)
      flash[:notice] = "The account for #{user['login']} was successfully deleted."
      user.destroy()
    end


    def protect?(action)
      if ['login', 'signup', 'forgot_password'].include?(action)
        return false
      else
        return true
      end
    end


    def generate_blank
      case request.method
      when :get
        @user = User.new
        render
        return true
      end
      return false
    end


    def generate_filled_in
      get_user_to_act_on
      case request.method
      when :get
        render
        return true
      end
      return false
    end


    def get_user_to_act_on
      @user = session[:user]
    end


    def do_delete_user(user)
      begin
        if LoginEngine.config(:delayed_delete)
          User.transaction(user) do
            key = user.set_delete_after
            if LoginEngine.config(:use_email_notification)
              url = url_for(:action => 'restore_deleted', :user_id => user.id, :key => key)
              UserNotify.deliver_pending_delete(user, url)
            end
          end
        else
          destroy(@user)
        end
        return true
      rescue
        if LoginEngine.config(:use_email_notification)
          flash.now[:warning] = 'The delete instructions were not sent. Please try again later.'
        else
          flash.now[:notice] = 'The account has been scheduled for deletion. It will be removed in #{LoginEngine.config(:delayed_delete_days)} days.'
        end
        return false
      end
    end
    
    def user_content_columns_to_display
      # we don't want people to see the passwords (even though they)
      # are hashed up...
      desired_columns = ["salted_password", "salt", "security_token", "token_expiry"]
      User.content_columns.delete_if { |c| desired_columns.include?(c.name) }
    end
end
