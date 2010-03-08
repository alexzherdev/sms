ActionController::Routing::Routes.draw do |map|
  map.resource :mailbox do |mailbox|
    mailbox.folder "folder", :controller => "mailboxes", :action => "folder" 
    mailbox.folders "folders", :controller => "mailboxes", :action => "folders"
    mailbox.sent "sent", :controller => "mailboxes", :action => "sent" 
    mailbox.trash "trash", :controller => "mailboxes", :action => "trash" 
    
    mailbox.resources :messages, :collection => { :reply => :post }
  end

  map.save_schedule "schedule/save", :controller => "schedules", :action => "save" 
 
  map.resource :schedule, :member => { :save => :post, :generate => :get }

  map.resources :teacher_subjects

  map.resources :subjects, :collection => { :import => :post }

  map.resources :student_groups

  map.resources :students, :collection => { :import => :post }

  map.resources :user_sessions
  
  map.resources :time_table_items
  
  map.resources :class_rooms
  
  map.resources :users
  
  map.connect "/register", :controller => "registers", :action => "show"
  
  map.final_register "register/final", :controller => "registers", :action => "final"
  map.resource :register, :member => { :mark => :post }
  
  map.resources :roles

  map.resources :years
  
  map.resources :news, :singular => :news_item
  
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
  map.root :controller => "news"

  # See how all your routes lay out with "rake routes"

  map.login "login", :controller => "user_sessions", :action => "new"  
  map.logout "logout", :controller => "user_sessions", :action => "destroy"  

  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
