# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include LoginEngine
  include UserEngine
  DEFAULT_OPTIONS = {:name => 'page', :window_size => 2, :always_show_anchors => true, :link_to_current_page => false}
  
  def page_title
    @page_title = "popcurrent.com - Where you are the critic."
  end

  def get_all_categories
		@categories = Category.find(:all)
  end
  
  def get_all_categories_array
		@categories = Category.find(:all).map {|c| [c.category_name, c.id] }
  end
  
  def set_default_focus(element)
		%{<script type="text/javascript">$("#{element}").focus();</script>}
  end

  def submit_button(form_name, prompt, html_options)
    %{<input name="submit" type="submit" value="#{prompt}" />}
  end

  def get_current_page_action
    if(@session[:current_page] == $page_hotnow)
      get_current_page_action = "frontpage_list"
    elsif(@session[:current_page] == $page_newestentries)
      get_current_page_action = "newest_list"
    elsif(@session[:current_page] == $page_bestentries)
      get_current_page_action = "popular_list"
    elsif(@session[:current_page] == $page_poppedbyfriends)
      get_current_page_action = "popped_by_friends_list"
    elsif(@session[:current_page] == $page_floppedbyfriends)
      get_current_page_action = "flopped_by_friends_list"
    elsif(@session[:current_page] == $page_submittedbyfriends)
      get_current_page_action = "submitted_by_friends_list"
    elsif(@session[:current_page] == $page_commentedbyfriends)
      get_current_page_action = "comments_by_friends_list"
    elsif(@session[:current_page] == $page_tagresults)
      get_current_page_action = "tags"
    elsif(@session[:current_page] == $page_searchresults)
      get_current_page_action = "search"
    else
      get_current_page_action = "frontpage_list"
    end
  end
  
  def top_users(max=3)
    @top_users = User.find(:all, :include => [:profile], :order => 'profiles.vote_total desc', :limit => max)
  end

  def random_users(max=3)
    @session[:profile_vote_avg] = Submission.average(:vote_total, :conditions => 'vote_total > 0').to_s if (!@session[:profile_vote_avg])
    
    @random_users = User.find(:all, :select => "us.*", :joins => "as us INNER JOIN profiles AS p ON us.id = p.user_id", :conditions => "p.image_url <> '' AND p.vote_total >= " + @session[:profile_vote_avg], :order => 'rand()', :limit => max)
  end

  def new_by_category(max, categoryName)
    date = Time.now - 168.hours
    @new_by_category = Submission.find(:all, 
                                       :select => "sub.id, sub.url, sub.title, sub.image_url, sub.user_id, p.user_id, p.vote_total",
                                       :joins => "as sub INNER JOIN profiles AS p ON sub.user_id = p.user_id",
                                       :conditions => ["sub.image_url <> '' AND category = '" + categoryName + "' AND created_at > ? AND p.vote_total > -1", date],
                                       :order => 'rand()', 
                                       :limit => max)
    
    if(@new_by_category.size != 3)
      @new_by_category = Submission.find(:all, 
                                         :select => "sub.id, sub.url, sub.title, sub.image_url, sub.user_id, p.user_id, p.vote_total",
                                         :joins => "as sub INNER JOIN profiles AS p ON sub.user_id = p.user_id",
                                         :conditions => ["sub.image_url <> '' AND category = '" + categoryName + "' AND p.vote_total > -1"],
                                         :order => 'created_at DESC', 
                                         :limit => max)
    end
  end
  
  def list_pagination_links_each(paginator, options)
     options = DEFAULT_OPTIONS.merge(options)
     link_to_current_page = options[:link_to_current_page]
     always_show_anchors = options[:always_show_anchors]
  
     current_page = paginator.current_page
     window_pages = current_page.window(options[:window_size]).pages
     return if window_pages.length <= 1 unless link_to_current_page
         
     first, last = paginator.first, paginator.last
         
     html = ''
     if always_show_anchors and not (wp_first = window_pages[0]).first?
       html << yield(first.number)
       html << '<span>...</span>' if wp_first.number - first.number > 1
       html << ' '
     end
         
     window_pages.each do |page|
       if current_page == page && !link_to_current_page
         html << "<span class='current'>" + page.number.to_s + "</span>"
       else
         html << yield(page.number)
       end
       html << ' '
     end
         
     if always_show_anchors and not (wp_last = window_pages[-1]).last? 
       html << '<span>...</span>' if last.number - wp_last.number > 1
       html << yield(last.number)
     end
         
     html
  end
  
  # Identical to +pagination_links+ except uses +link_to_remote+ instead of
  # +link_to+.  Additional options are:
  # +:update+::   same as in +link_to_remote+
  def pagination_links_remote(paginator, options={})
    update = options.delete(:update)
    action = options.delete(:action)
    str = pagination_links(paginator, options)
    if str != nil
      str = str.gsub(/\?/, "/#{action}?") if(str !~ /#{action}/)
      str.gsub(/href="([^"]*)"/) do
        url = $1
        "href=\"#\" onclick=\"new Ajax.Updater('" + update + "', '" + url +
        "', {asynchronous:true, evalScripts:true}); return false;\"" 
      end
    end
  end

  def calced_time_since_submission
    hours = time_ago_in_words(@submission.created_at)
    calcedTimeSinceSubmission = hours + "&nbsp;ago"
  end
  
  #Return int
  #0 = user has not voted yet on this submission
  #1 = user has poped this submission
  #2 = user has flopped this submission
  def has_voted
    has_voted = 0
    if session[:user]
      if @submission.sub_pops.find_by_user_id(session[:user].id) 
        has_voted = 1
      elsif @submission.sub_flops.find_by_user_id(session[:user].id)
        has_voted = 2
      end
    end
    return has_voted
  end
  
  #Return int
  #0 = user has not voted yet on this profile
  #1 = user has poped this profile
  #2 = user has flopped this profile
  def profile_has_voted
    profile_has_voted = 0
    if session[:user]
      if @user.profile.profile_pops.find_by_user_id(session[:user].id) 
        profile_has_voted = 1
      elsif @user.profile.profile_flops.find_by_user_id(session[:user].id)
        profile_has_voted = 2
      end
    end
    return profile_has_voted
  end
  
  def format_nobreak(str)
    return str.gsub(/ /, '&nbsp;')
  end  
  
  def get_activity_popped_count
      date = Time.now - 48.hours
      @activity_entries = Submission.find(:all,
                                        :select => "DISTINCT submissions.id",
                                        :joins => "INNER JOIN sub_pops sp ON submissions.id = sp.submission_id",
                                        :conditions => ["sp.created_at > ? AND sp.user_id IN (SELECT p.user_id FROM profiles p INNER JOIN friends f ON p.id = f.profile_id WHERE f.user_id = ?)", date, current_user.id], 
                                        :order => "submissions.created_at DESC")
    

      return @activity_entries.length
  end

  def get_activity_flopped_count
    date = Time.now - 48.hours
    @activity_entries = Submission.find(:all,
                                        :select => "DISTINCT submissions.id",
                                        :joins => "INNER JOIN sub_flops sp ON submissions.id = sp.submission_id",
                                        :conditions => ["sp.created_at > ? AND sp.user_id IN (SELECT p.user_id FROM profiles p INNER JOIN friends f ON p.id = f.profile_id WHERE f.user_id = ?)", date, current_user.id], 
                                        :order => "submissions.created_at DESC")
    
    return @activity_entries.length
  end

  def get_activity_submitted_count
    date = Time.now - 48.hours
    @activity_entries = Submission.find(:all,
                                        :select => "DISTINCT submissions.id",
                                        :conditions => ["submissions.created_at > ? AND submissions.user_id IN (SELECT p.user_id FROM profiles p INNER JOIN friends f ON p.id = f.profile_id WHERE f.user_id = ?)", date, current_user.id], 
                                        :order => "submissions.created_at DESC")
    
    return @activity_entries.length
  end
  
  def get_activity_comments_count
      date = Time.now - 48.hours
      @activity_entries = Submission.find(:all,
                                        :select => "DISTINCT submissions.id",
                                        :joins => "INNER JOIN comments sp ON submissions.id = sp.submission_id",
                                        :conditions => ["sp.created_at > ? AND sp.user_id IN (SELECT p.user_id FROM profiles p INNER JOIN friends f ON p.id = f.profile_id WHERE f.user_id = ?)", date, current_user.id], 
                                        :order => "submissions.created_at DESC")
    

      return @activity_entries.length
  end
  
  def get_account_name
    if(current_user)
      if(current_user.firstname != "" && current_user.lastname != "")
        @name = current_user.firstname + " " +  current_user.lastname
      elsif(current_user.firstname != "")
        @name = current_user.firstname 
      else
        @name = current_user.login
      end
    else
      @name = "Someone"    
    end
  end
  
end
