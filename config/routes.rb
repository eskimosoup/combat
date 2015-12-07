ActionController::Routing::Routes.draw do |map|

  map.login '/login', :controller => 'session', :action => 'new'

  map.logout '/logout', :controller => 'session', :action => 'destroy'

  map.root :controller => "web", :action => "content1"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect '/admin', :controller => 'login', :action => 'home'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
