ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  map.connect '', :controller => 'submissions'
  map.connect '/directory.opml', :controller => 'application', :action => 'opml_directory'
  map.connect '/login', :controller => 'user', :action => 'login'
  map.connect '/invite', :controller => 'application', :action => 'invite_form'
  map.connect '/best', :controller => 'submissions', :action => 'popular_list'
  map.connect '/popular', :controller => 'submissions', :action => 'popular_list'
  map.connect '/worst', :controller => 'submissions', :action => 'unpopular_list'
  map.connect '/newest', :controller => 'submissions', :action => 'newest_list'
  map.connect '/hot/', :controller => 'submissions', :action => 'frontpage_list'
  map.connect '/hot/:filter', :controller => 'submissions', :action => 'frontpage_list'
  map.connect '/popular/:filter', :controller => 'submissions', :action => 'popular_list'
  map.connect '/best/:filter', :controller => 'submissions', :action => 'popular_list'
  map.connect '/worst/:filter', :controller => 'submissions', :action => 'unpopular_list'
  map.connect '/newest/:filter', :controller => 'submissions', :action => 'newest_list'
  map.connect '/river', :controller => 'submissions', :action => 'river_list'
  map.connect '/river.opml', :controller => 'submissions', :action => 'opml_river_directory'
  map.connect '/river/:type', :controller => 'submissions', :action => 'river_list'
  map.connect '/river/:type/:value', :controller => 'submissions', :action => 'river_list'
  map.connect '/river/:type/:value/:type2', :controller => 'submissions', :action => 'river_list'
  map.connect '/popped_by_friends', :controller => 'submissions', :action => 'popped_by_friends_list'
  map.connect '/flopped_by_friends', :controller => 'submissions', :action => 'flopped_by_friends_list'
  map.connect '/submitted_by_friends', :controller => 'submissions', :action => 'submitted_by_friends_list'
  map.connect '/comments_by_friends', :controller => 'submissions', :action => 'comments_by_friends_list'
  map.connect '/search/', :controller => 'submissions', :action => 'search'
  map.connect '/search/:query', :controller => 'submissions', :action => 'search'
  map.connect '/rss/', :controller => 'submissions', :action => 'rss'
  map.connect '/rss/:type', :controller => 'submissions', :action => 'rss'
  map.connect '/rss/:type/:value', :controller => 'submissions', :action => 'rss'
  map.connect '/rss/:type/:value/:type2', :controller => 'submissions', :action => 'rss'
  map.connect '/critics.opml', :controller => 'user', :action => 'opml_critics_directory'
  map.connect '/critics', :controller => 'user', :action => 'list'
  map.connect '/critics/:user/rss', :controller => 'user', :action => 'rss'
  map.connect '/critics/:user/rss/:type', :controller => 'user', :action => 'rss'
  map.connect '/critics/:user/friends.opml', :controller => 'user', :action => 'opml'
  map.connect '/submit', :controller => 'submissions', :action => 'new'
  map.connect '/whatIsPopCurrent', :controller => 'application', :action => 'whatIsPopCurrent'
  map.connect '/tos', :controller => 'application', :action => 'tos'
  map.connect '/privacy', :controller => 'application', :action => 'privacy'
  map.connect '/entries/', :controller => 'submissions', :action => 'frontpage_list'
  map.connect '/entries/:urlname', :controller => 'submissions', :action => 'urlname'
  map.connect '/entries/postComment/:id', :controller => 'submissions', :action => 'post_comment'
  map.connect '/submissions/postComment/:id', :controller => 'submissions', :action => 'post_comment'
  map.connect '/tag/', :controller => 'submissions', :action => 'tags' 
  map.connect '/tag/:tag', :controller => 'submissions', :action => 'tags'
  
  map.connect '/api/entries/:urlname', :controller => 'api', :action => 'entries'
  map.connect '/api/entrypromo/:urlname', :controller => 'api', :action => 'entrypromo'
  map.connect '/api/podcastpromo/:rssurl', :controller => 'api', :action => 'podcastpromo'
  map.connect '/api/user_pops/:user', :controller => 'api', :action => 'user_pops'
  
  map.user_page '/critics/:user', :controller => 'user', :action => 'profile'
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
