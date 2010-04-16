ActionController::Routing::Routes.draw do |map|
 
# 'new' UI paths all start with '/n/'
#
  map.juris_elections "/n/", :controller => :elections, :action => :jurisdiction_index
  map.change_jurisdiction "/n/change_jurisdiction", :controller => :elections, :action => :set_jurisdiction
  
  map.resources :candidates, :except => [:create]
  map.resources :contests, :has_many => :candidates
  map.resources :districts
  map.resources :district_sets
  map.resources :district_types
  map.resources :elections, :member => { :export => :get, :precincts => :get , :translate => :put }, 
                            :collection => { :import => :put, :import_yml => :put } do | elections |
    elections.resources :districts do | districts | 
      districts.resources :contests, :only => [:new]
      districts.resources :questions, :only => [:new]
    end
    elections.resources :precincts, :member => { :ballot => :get }, :only => []
    elections.resources :contests
  end
  map.resources :parties
  map.resources :precincts
  map.resources :questions
  map.resources :voting_methods
  map.resources :ballot_styles, :only => [:index]
  
  map.resources :password_resets
  map.resources :users
  map.resources :user_sessions
  map.login "login", :controller => 'user_sessions', :action => 'new'
  map.logout "logout", :controller => 'user_sessions', :action => 'destroy'
  map.maintain '/maintain/:action', :controller => 'maintain'
  map.root :controller => "application", :action=>"index"

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
#  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'
end
