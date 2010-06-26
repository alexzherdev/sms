Sms::Application.routes.draw do
  resource :mailbox do
    match 'folder' => 'mailboxes#folder', :as => :folder
    match 'folders' => 'mailboxes#folders', :as => :folders
    match 'sent' => 'mailboxes#sent', :as => :sent
    match 'trash' => 'mailboxes#trash', :as => :trash
    resources :messages do
      collection do
        post :reply_all
        post :restore
        post :forward
        post :delete
        post :reply
      end    
    end
  end

  match 'schedule/save' => 'schedules#save', :as => :save_schedule
  resource :schedule do
    member do
      get :generate
      post :save
    end
  end

  resources :teacher_subjects
  resources :subjects do
    collection do
      post :import
    end  
  end

  resources :student_groups
  resources :students do
    collection do
      post :import
    end
  end

  resources :user_sessions
  resources :time_table_items
  resources :class_rooms
  resources :users
  
  match '/register' => 'registers#show'
  match 'register/final' => 'registers#final', :as => :final_register
  resource :register do
    member do
      post :mark
    end
  end

  resources :roles
  resources :years
  resources :news
  match '/search' => 'search#index', :as => :search

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  
  root :to => 'news#index'
    
  match '/:controller(/:action(/:id))'
end
