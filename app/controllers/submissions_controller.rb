#********************************************************
# Filename:       submissions_controller.rb
# Authors:        Sean Jackson, Ray Slakinski
# Created:        April 2006
#
# Actions to manage Submissions
#
# Copyright 2006 popcurrent.com. All rights reserved.
#********************************************************
class SubmissionsController < ApplicationController
  
  before_filter :login_required, :only => [:new, :edit, :update, 
                                           :create, :destroy, :pop_it, 
                                           :flop_it, :blip, :popped_by_friends_list, 
                                           :flopped_by_friends_list, :submitted_by_friends_list,
                                           :comments_by_friends_list]
  
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify(:method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list })


 
  def index
    frontpage_list
  end

  
  def tags
    set_session_variables(params, request, $page_tagresults)
    
    tag = params[:tag] || ''
    if(tag != '')
      @session[:current_tag] = tag
    else
      tag = @session[:current_tag] || ''
    end
    
    @submission_pages, @submissions = paginate(:submissions,
                                               :select => "DISTINCT s.*",
                                               :joins => "AS s INNER JOIN taggings ts ON s.id = ts.taggable_id INNER JOIN tags tg ON ts.tag_id = tg.id",
                                               :per_page => Integer(@session[:items_per_page]), 
                                               :conditions => ["(" + @cat_conditions + ") AND " +
                                                               "ts.taggable_type = 'Submission' " +
                                                               "AND tg.name = ?", tag],
                                               :order => "s.vote_total DESC")
    
    if(request.xhr?)  
      render(:action => "list", :layout => false)
    else
      render(:action => "list", :layout => "standard")
    end
  end


  def set_session_variables(params,request,page)
    @session[:current_page] = page

    if @session[:submission_vote_avg].nil? or @session[:profile_vote_avg].nil? or @session[:items_per_page].nil?
      date = Time.now - 30.days
      
      @session[:items_per_page] = "10"
      
      @session[:submission_vote_avg] = Submission.average(:vote_total, :conditions => ['vote_total > 0 and created_at > ?', date]).to_s
      @session[:profile_vote_avg] = Profile.average(:vote_total, :conditions => 'vote_total > 0').to_s
    end
  
    if(params[:filter])
      @params[:filter] = @params[:filter].downcase.titleize
      if(@params[:filter] == "All")
        @session[:filter] = "all"
        @cat_conditions = "category <> 'all'"
      else
        @session[:filter] = @params[:filter]
        @cat_conditions = "category = '" + @params[:filter] + "'"
      end
    else
      if(@session[:filter].nil?)
        @session[:filter] = "All"
        @cat_conditions = "category <> 'all'"
      else
        if(@session[:filter] == "all" || @session[:filter] == "All")
          @cat_conditions = "category <> 'all'"
        else  
          @cat_conditions = "category = '" + @session[:filter].to_s  + "'"
        end
      end
    end
  end

  
  def frontpage_list
    set_session_variables(params, request, $page_hotnow)
    
    @submission_pages, @submissions = paginate(:submissions, 
                                                 :per_page => Integer(@session[:items_per_page]), 
                                                 :conditions => '(' + @cat_conditions + ') AND (submissions.vote_total >= ' + @session[:submission_vote_avg] + ')', 
                                                 :order => "submissions.created_at DESC")
    
    if(request.xhr?)  
      render(:action => "list", :layout => false)
    else
      render(:action => "list")
    end
  end


  def newest_list
    set_session_variables(params,request, $page_newestentries)
    
    @submission_pages, @submissions = paginate(:submissions, 
                                               :per_page => Integer(@session[:items_per_page]), 
                                               :conditions => @cat_conditions,
                                               :order => "created_at DESC")

    if(request.xhr?)  
      render(:action => "list", :layout => false)
    else
      render(:action => "list")
    end
  end

  # Similar to newest, just lighter weight view
  def river_list
    @session[:current_page] = $page_other
    @session[:submission_vote_avg] = Submission.average(:vote_total, :conditions => 'vote_total > 0').to_s
    
    if params[:type]
      case params[:type]
      when "hot"                                     
        @submissions = Submission.find(:all, :conditions => '(submissions.vote_total >= ' + @session[:submission_vote_avg] + ')', :order => "submissions.created_at desc", :limit => 40)
      when "best"
        @submissions = Submission.find(:all, :order => "vote_total desc", :limit => 40)
      when "worst"
        @submissions = Submission.find(:all, :order => "vote_total asc", :limit => 40)
      when "newest"
        @submissions = Submission.find(:all, :order => "created_at desc", :limit => 40)
      when "tag"
        if params[:value]
          tag = params[:value]
        else
          tag = ''
        end
        @submissions = Submission.find_tagged_with(tag)
      when "cat"
        if params[:value]
          cat = "category = '" + String(params[:value]) + "'"
        else
          cat = "category <> 'all'"
        end
        if params[:type2]
          case params[:type2]
          when "hot"                                     
            @submissions = Submission.find(:all, :conditions => '(' + cat + ') and (submissions.vote_total >= ' + @session[:submission_vote_avg] + ')', :order => "submissions.created_at desc", :limit => 40)
          when "best"
            @submissions = Submission.find(:all, :conditions => '(' + cat + ')', :order => "vote_total desc", :limit => 40)
          when "worst"
            @submissions = Submission.find(:all, :conditions => '(' + cat + ')', :order => "vote_total asc", :limit => 40)
          when "newest"
            @submissions = Submission.find(:all, :conditions => '(' + cat + ')', :order => "created_at desc", :limit => 40)
          else
            @submissions = Submission.find(:all, :conditions => '(' + cat + ')', :order => "created_at desc", :limit => 40)
          end
        end
      else
        @submissions = Submission.find(:all, :conditions => '(submissions.vote_total >= ' + @session[:submission_vote_avg] + ')', :order => "submissions.created_at desc", :limit => 40)
      end
    else
      params[:type] = "hot"
      @submissions = Submission.find(:all, :conditions => '(submissions.vote_total >= ' + @session[:submission_vote_avg] + ')', :order => "submissions.created_at desc", :limit => 40)
    end

    render(:action => "river_list", :layout => false)
  end

  def popular_list
    set_session_variables(params,request,$page_bestentries)
    
    @submission_pages, @submissions = paginate(:submissions, 
                                               :per_page => Integer(@session[:items_per_page]), 
                                               :conditions => @cat_conditions,
                                               :order => "vote_total DESC")

    if(request.xhr?)  
      render(:action => "list", :layout => false)
    else
      render(:action => "list")
    end
  end

  
  def unpopular_list
    set_session_variables(params,request,$page_other)
    
    @submission_pages, @submissions = paginate(:submissions, 
                                               :per_page => Integer(@session[:items_per_page]), 
                                               :conditions => @cat_conditions,
                                               :order => "vote_total ASC")

    if(request.xhr?)  
      render(:action => "list", :layout => false)
    else
      render(:action => "list")
    end
  end

  
  def popped_by_friends_list
   if(current_user)
     set_session_variables(params,request,$page_poppedbyfriends)

     date = Time.now - 48.hours
     @submission_pages, @submissions = paginate(:submissions, 
                                                :select => "DISTINCT submissions.*",
                                                :per_page => Integer(@session[:items_per_page]), 
                                                :joins => "JOIN urlnames un ON submissions.id = un.nameable_id INNER JOIN sub_pops sp ON submissions.id = sp.submission_id",
                                                :conditions => ["sp.created_at > ? AND sp.user_id IN (SELECT p.user_id FROM profiles p INNER JOIN friends f ON p.id = f.profile_id WHERE f.user_id = ?) AND ("+ @cat_conditions +")", date, current_user.id], 
                                                :count => 'distinct submissions.id',
                                                :order => "submissions.created_at DESC")

     if(request.xhr?)  
       render(:action => "list", :layout => false)
     else
       render(:action => "list")
     end
   else
     render(:action => "frontpage_list")
   end
  end


  def flopped_by_friends_list
    if(current_user)
      set_session_variables(params,request, $page_floppedbyfriends)

      date = Time.now - 48.hours
      @submission_pages, @submissions = paginate(:submissions, 
                                                 :select => "DISTINCT submissions.*",
                                                 :per_page => Integer(@session[:items_per_page]), 
                                                 :joins => "JOIN urlnames un ON submissions.id = un.nameable_id INNER JOIN sub_flops sp ON submissions.id = sp.submission_id",
                                                 :conditions => ["sp.created_at > ? AND sp.user_id IN (SELECT p.user_id FROM profiles p INNER JOIN friends f ON p.id = f.profile_id WHERE f.user_id = ?) AND ("+ @cat_conditions +")", date, current_user.id], 
                                                 :count => 'distinct submissions.id',
                                                 :order => "submissions.created_at DESC")

      if(request.xhr?)  
        render(:action => "list", :layout => false)
      else
        render(:action => "list")
      end
    else
      render(:action => "frontpage_list")
    end
  end


  def submitted_by_friends_list
    if(current_user)
      set_session_variables(params,request, $page_submittedbyfriends)

      date = Time.now - 48.hours
      @submission_pages, @submissions = paginate(:submissions, 
                                                 :per_page => Integer(@session[:items_per_page]), 
                                                 :conditions => ["submissions.created_at > ? AND submissions.user_id IN (SELECT p.user_id FROM profiles p INNER JOIN friends f ON p.id = f.profile_id WHERE f.user_id = ?) AND ("+ @cat_conditions +")", date, current_user.id], 
                                                 :order => "submissions.created_at DESC")

      if(request.xhr?)  
        render(:action => "list", :layout => false)
      else
        render(:action => "list")
      end
    else
      render(:action => "frontpage_list")
    end
  end
  
  def comments_by_friends_list
    if(current_user)
      set_session_variables(params,request, $page_commentedbyfriends)

      date = Time.now - 48.hours
      @submission_pages, @submissions = paginate(:submissions, 
                                                 :select => "DISTINCT submissions.*",
                                                 :per_page => Integer(@session[:items_per_page]), 
                                                 :joins => "JOIN urlnames un ON submissions.id = un.nameable_id INNER JOIN comments cm ON submissions.id = cm.submission_id",
                                                 :conditions => ["cm.created_at > ? AND cm.user_id IN (SELECT p.user_id FROM profiles p INNER JOIN friends f ON p.id = f.profile_id WHERE f.user_id = ?) AND ("+ @cat_conditions +")", date, current_user.id], 
                                                 :count => 'distinct submissions.id',
                                                 :order => "submissions.created_at DESC")

      if(request.xhr?)  
        render(:action => "list", :layout => false)
      else
        render(:action => "list")
      end
    else
      render(:action => "frontpage_list")
    end
  end

 
  def search
    #To set current page for tabs in _header.rhtml
    set_session_variables(params, request, $page_searchresults)
    
    @session[:items_per_page] = "10" if (!@session[:items_per_page])
    
    query = params[:query] || ''
    if(query != '')
      @session[:current_query] = query
    else
      query = @session[:current_query] || ''
    end
    
    @submission_pages, @submissions = paginate(:submissions,
                                               :select => "DISTINCT s.*",
                                               :joins => "AS s INNER JOIN search_terms_submissions ts ON s.id = ts.submission_id INNER JOIN search_terms tg ON ts.search_term_id = tg.id",
                                               :per_page => Integer(@session[:items_per_page]), 
                                               :conditions => ["(" + @cat_conditions + ") AND tg.term = ?", query],
                                               :order => "s.vote_total DESC")
       
    if(request.xhr?)  
      render(:action => "list", :layout => false)
    else
      render(:action => "list", :layout => "standard")
    end
  end


  def list
  end

  def show
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_single_entry
    
    @submission = Submission.find(params[:id])
  
    if(request.xhr?)  
      render(:layout => false)
    else
      render(:layout => "single_entry")
    end
  end

  
  def show_sub_users
    @submission = Submission.find(params[:id])
    if(params[:subtype] == "sub_pop")
      @sub_user_pages, @sub_users = paginate(:sub_pops,
                                           :conditions => ["submission_id = ?",@submission.id],
                                           :per_page => 25)
    elsif(params[:subtype] == "sub_flop")
      @sub_user_pages, @sub_users = paginate(:sub_flops,
                                           :conditions => ["submission_id = ?",@submission.id],
                                           :per_page => 25)
    elsif(params[:subtype] == "friends")
      @pop_flops = @submission.sub_pops + @submission.sub_flops
      
      if(current_user)
        @sub_users = Array.new
        for @pop_flop in @pop_flops
            for @friend in current_user.friends
              if @friend.profile.user_id == @pop_flop.user_id
                @sub_users << @pop_flop
              end
            end
        end
      end
    else
      @sub_user_pages, @sub_users = paginate(:sub_pops,
                                           :conditions => ["submission_id = ?",@submission.id],
                                           :per_page => 25)
    end
    render(:layout => false)
  end


  def show_history
    @user = User.find(params[:id])
    if(params[:subtype] == "popped")
      @history_pages, @results = paginate(:sub_pops,
                                           :conditions => ["sub_pops.user_id = ?",@user.id],
                                           :include => [:submission],
                                           :per_page => 10,
                                           :order => "submissions.created_at DESC")
    elsif(params[:subtype] == "flopped")
      @history_pages, @results = paginate(:sub_flops,
                                           :conditions => ["sub_flops.user_id = ?",@user.id],
                                           :include => [:submission],
                                           :per_page => 10,
                                           :order => "submissions.created_at DESC")

     elsif(params[:subtype] == "submitted")
       @history_pages, @results = paginate(:submissions,
                                           :conditions => ["user_id = ?",@user.id],
                                           :per_page => 10,
                                           :order => "submissions.created_at DESC")
    else
      @history_pages, @results = paginate(:sub_pops,
                                           :conditions => ["sub_pops.user_id = ?",@user.id],
                                           :include => [:submission],
                                           :per_page => 10,
                                           :order => "submissions.created_at DESC")
    end
    render(:layout => false)
  end


  def recommendations
    @sub = Submission.find(params[:id])
    
    if(current_user)
      @submissions = Submission.find(:all,
                                     :select => "DISTINCT submissions.*",
                                     :joins => "JOIN sub_pops ON sub_pops.submission_id = submissions.id",
                                     :conditions => ["sub_pops.user_id IN (SELECT sub_pops.user_id FROM sub_pops WHERE sub_pops.submission_id = ?)
                                      AND sub_pops.submission_id NOT IN (SELECT sub_pops.submission_id FROM sub_pops WHERE sub_pops.user_id = ?) 
                                      AND sub_pops.submission_id NOT IN (SELECT sub_flops.submission_id FROM sub_flops WHERE sub_flops.user_id = ?) 
                                      AND sub_pops.submission_id <> ? AND submissions.category = ? AND submissions.image_url <> ''", @sub.id, current_user.id, current_user.id, @sub.id, @sub.category],
                                     :order => "submissions.vote_total DESC",
                                     :limit => 8)
    else
      @submissions = Submission.find(:all,
                                     :select => "DISTINCT submissions.*",
                                     :joins => "JOIN sub_pops ON sub_pops.submission_id = submissions.id",
                                     :conditions => ["sub_pops.user_id IN (SELECT sub_pops.user_id FROM sub_pops WHERE sub_pops.submission_id = ?)
                                      AND sub_pops.submission_id <> ? AND submissions.category = ? AND submissions.image_url <> ''", @sub.id, @sub.id, @sub.category],
                                     :order => "submissions.vote_total DESC",
                                     :limit => 8)
    end  

    render(:layout => false)
  end


  def new
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_submit

    if request.get?
			  @submission = Submission.new
		else
			@submission = Submission.new(params[:submission])
	    @submission.save
		end

    if params[:url]
      if submission = Submission.find_by_url(params[:url])
        redirect_to(:action => 'urlname', :urlname => submission.urlname)
      else
        render(:layout => "forms")
      end
    else
      render(:layout => "forms")
    end
    
    
  end


  def create
    @submission = @session[:user].submissions.create(params[:submission])

    if(@params[:pop][:autopop] == "1")
      @submission.sub_pops << SubPop.new(:user_id => session[:user].id, :created_at => Time.now)
      @submission.vote_total = @submission.vote_total + 1
    end

    @addresses = @params[:email][:emailaddresses]
    @message = @params[:email][:emailmessage]
        
    if @submission.save
      @submission.tag_with(params[:tags])

      if(@addresses.length > 1)
        @link = url_for(:only_path => false, :controller => 'submissions', :action => :urlname, :urlname => @submission.urlname)
        @mailer = PopMailer.deliver_pop_mailer(@submission, @addresses, @message, @link)
        #render(:text => "<pre>" + @mailer.encoded + "</pre>")
      end

      flash[:success] = 'success'
      redirect_to(:action => 'urlname', :urlname => @submission.urlname)
    else
      flash[:success] = 'failed'
      render(:action => 'new', :layout => "forms")
    end
  end
  
  def post_comment
    @submission = Submission.find(params[:id])

    @comment = @submission.comments.create(:created_at => Time.now(), 
                                           :updated_at => Time.now(), 
                                           :parent_id => params[:comment][:parent_id], 
                                           :user_id => @session[:user].id, 
                                           :user_name => @session[:user].login, 
                                           :subject => params[:comment][:subject], 
                                           :body => params[:comment][:body])
    
    redirect_to(:action => 'urlname', :urlname => @submission.urlname)
  end


  def edit
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_other

    @submission = Submission.find(params[:id])
    
    if((authorized?(:controller => "user", :action => "edit_roles")) || (@submission.user_id == @session[:user].id && (@submission.created_at > (Time.now - 15.minutes))))
      render(:layout => "forms")
    else
      redirect_to(:action => 'urlname', :urlname => @submission.urlname)
    end
  end


  def update
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_other

    @submission = Submission.find(params[:id])
    params[:submission][:created_at] = @submission[:created_at]
    if params[:tags].length > 0
      @submission.tag_with(params[:tags])
    end
    
    if @submission.update_attributes(params[:submission])
      flash[:notice] = 'Submission was successfully updated.'
      redirect_to(:action => 'show', :id => @submission)
    else
      render(:action => 'edit', :layout => 'forms')
    end
  end


  def urlname
    #To set current page for tabs in _header.rhtml
    @session[:current_page] = $page_single_entry

    @submission = Submission.find_by_urlname(params[:urlname])
    if @submission
      if(request.xhr?)  
        render(:action => 'show',:layout => false)
      else
        render(:action => 'show',:layout => "single_entry")
      end

    else
      redirect_to("/")
    end
  end


  def destroy
    @submission = Submission.find(params[:id])
    if authorized?(:controller => "user", :action => "edit_roles")
      @submission.destroy
      SubPop.destroy_all(["submission_id = ?", params[:id]])
      SubFlop.destroy_all(["submission_id = ?", params[:id]])
      SubBlip.destroy_all(["submission_id = ?", params[:id]])
    
      redirect_to(:action => 'frontpage_list')
    else
      redirect_to(:action => 'urlname', :urlname => @submission.urlname)
    end
  end

  
  def rss
    if @session[:submission_vote_avg].nil?
      @session[:submission_vote_avg] = Submission.average(:vote_total, :conditions => 'vote_total > 0').to_s
    end
    if params[:type]
      case params[:type]
      when "hot"                                     
        @submissions = Submission.find(:all, :conditions => '(submissions.vote_total >= ' + @session[:submission_vote_avg] + ')', :order => "submissions.created_at desc", :limit => 40)
      when "best"
        @submissions = Submission.find(:all, :order => "vote_total desc", :limit => 40)
      when "worst"
        @submissions = Submission.find(:all, :order => "vote_total asc", :limit => 40)
      when "newest"
        @submissions = Submission.find(:all, :order => "created_at desc", :limit => 40)
      when "tag"
        if params[:value]
          tag = params[:value]
        else
          tag = ''
        end
        @submissions = Submission.find_tagged_with(tag)
      when "cat"
        if params[:value]
          cat = "category = '" + String(params[:value]) + "'"
        else
          cat = "category <> 'all'"
        end
        if params[:type2]
          case params[:type2]
          when "hot"                                     
            @submissions = Submission.find(:all, :conditions => '(' + cat + ') and (submissions.vote_total >= ' + @session[:submission_vote_avg] + ')', :order => "submissions.created_at desc", :limit => 40)
          when "best"
            @submissions = Submission.find(:all, :conditions => '(' + cat + ')', :order => "vote_total desc", :limit => 40)
          when "worst"
            @submissions = Submission.find(:all, :conditions => '(' + cat + ')', :order => "vote_total asc", :limit => 40)
          when "newest"
            @submissions = Submission.find(:all, :conditions => '(' + cat + ')', :order => "created_at desc", :limit => 40)
          else
            @submissions = Submission.find(:all, :conditions => '(' + cat + ')', :order => "created_at desc", :limit => 40)
          end
        end
      else
        @submissions = Submission.find(:all, :conditions => '(submissions.vote_total >= ' + @session[:submission_vote_avg] + ')', :order => "submissions.created_at desc", :limit => 40)
      end
    else
      params[:type] = "hot"
      @submissions = Submission.find(:all, :conditions => '(submissions.vote_total >= ' + @session[:submission_vote_avg] + ')', :order => "submissions.created_at desc", :limit => 40)
    end
    
    render_without_layout
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end
  
  
  def opml_river_directory
    render_without_layout
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end
  

  def pop_it
    @submission = Submission.find(params[:id])
    if(request.xhr?)
      if @submission.sub_pops.find_by_user_id(session[:user].id)  == nil and @submission.sub_flops.find_by_user_id(session[:user].id) == nil
        @submission.sub_pops << SubPop.new(:user_id => session[:user].id, :created_at => Time.now)
        @submission.vote_total = @submission.vote_total + 1
        @submission.save
      end
      render( :layout => false )
    else
      redirect_to(:action => 'urlname', :urlname => @submission.urlname)
    end
  end


  def un_pop
    @submission = Submission.find(params[:id])
    if(request.xhr?)
      @pop = @submission.sub_pops.find_by_user_id(session[:user].id)
    
      if @pop != nil 
        @pop.destroy()
        @submission.vote_total = @submission.vote_total - 1
        @submission.save
      end
      render( :layout => false )
    else
      redirect_to(:action => 'urlname', :urlname => @submission.urlname)
    end
  end


  def flop_it
    @submission = Submission.find(params[:id])
    if(request.xhr?)
      
      if !authorized?(:controller => "user", :action => "edit_roles")
        date = Time.now - 1.day
        @total_flops = SubFlop.find(:all,
                                    :conditions => ["user_id = " + String(session[:user].id) + " AND created_at > ?", date])

        if(!@total_flops.nil? && @total_flops.length >= 3)
          flash[:success] = 'toomanyflops'
          render( :layout => false )
          return
        end
      end
      
      if @submission.sub_pops.find_by_user_id(session[:user].id)  == nil and @submission.sub_flops.find_by_user_id(session[:user].id) == nil and @session[:user].profile.vote_total >= 0
        @submission.sub_flops << SubFlop.new(:user_id => session[:user].id, :created_at => Time.now)
        @submission.vote_total = @submission.vote_total - 1
        @submission.save
      end
      render( :layout => false )
    else
      redirect_to(:action => 'urlname', :urlname => @submission.urlname)
    end
  end


  def un_flop
    @submission = Submission.find(params[:id])
    if(request.xhr?)
      @flop = @submission.sub_flops.find_by_user_id(session[:user].id)
    
      if @flop != nil
        @flop.destroy()
        @submission.vote_total = @submission.vote_total + 1
        @submission.save
      end
      render( :layout => false )
    else
      redirect_to(:action => 'urlname', :urlname => @submission.urlname)
    end
  end


  def blip_it
    @submission = Submission.find(params[:id])
    if Integer(params['bliptype'+String(params[:id])]) > 0
      @submission = Submission.find(params[:id], :include => [:user, :sub_blips])
      if !@submission.sub_blips.find_by_user_id(session[:user].id)
        @submission.sub_blips << SubBlip.new(:user_id => session[:user].id, :created_at => Time.now, :bliptype => Integer(params['bliptype'+String(params[:id])]))
        @submission.save
      end 
    end
    render( :layout => false )
  end
  
  def pop_wars
    @submissions = Submission.find(:all,
                                   :conditions => "vote_total >= 0 AND vote_total < " +
                                                   @session[:submission_vote_avg].to_s, 
                                   :order => 'rand()',
                                   :limit => 2)
    
    render(:layout => false)
  end
  
  def send_email
    @submission = Submission.find(params[:id])
    if(@params[:email][:emailaddresses])
      @addresses = @params[:email][:emailaddresses]
    else
      @addresses = ""
    end
    
    if(@params[:email][:emailmessage])
      @message = @params[:email][:emailmessage]
    else
      @message = ""
    end
    
    @link = url_for(:only_path => false, :controller => 'submissions', :action => :urlname, :urlname => @submission.urlname)

    case request.method
      when :post
        if(@addresses.length > 1)
          
          @valid_addresses = @addresses.split(",")
          for @valid_address in @valid_addresses
            if(!valid_email(@valid_address))
              flash[:warning] = 'You have entered an invalid email address near "' + @valid_address + "'."
              render(:layout => false)
              return
            end
          end
          
          @link = url_for(:only_path => false, :controller => 'submissions', :action => :urlname, :urlname => @submission.urlname)
          @mailer = PopMailer.deliver_pop_mailer(@submission, @addresses, @message, @link)
          #render(:text => "<pre>" + @mailer.encoded + "</pre>")
          
          flash[:notice] = 'Your email was sent sucessfully!'
        else
          flash[:warning] = 'Could not send email due to blank or invalid email addresses.'
        end
    end
    render(:layout => false)
  end

end
