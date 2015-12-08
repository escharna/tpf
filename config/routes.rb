Rails.application.routes.draw do

  resources :sub_event_types

  resources :preference_types

  resources :preferences

  resources :restaurants

  resources :events do
    resources :sub_events
    get '/sub_events/:id/sign_up', to: 'sub_events#sign_up', as: :sign_up
    get '/sub_events/:id/task_remove', to: 'sub_events#task_remove', as: :task_remove
  end

  get '/sub_events/:id/roster', to: 'sub_events#roster', as: :roster

  post '/sub_events/:id/calculate_hours', to: 'sub_events#calculate_hours', as: :calculate_hours
  post '/sub_events/:id/edit_attendance', to: 'sub_events#edit_attendance', as: :edit_attendance

  get '/users/approve_users'

  post 'users/:id/approve', :to => 'users#approve', :as => 'user_approve'

  resources :event_types

  authenticated do
    root :to => 'events#index', as: :authenticated
  end

  root :to => 'home#index'

  get '/sub_events/:id/complete_task', :to => 'sub_events#complete_task', as: :complete_task
  #root 'users#dashboard'

  #devise_for :users

  post '/sub_events/:id/remove_user_from_task', to: 'sub_events#remove_user_from_task', as: :remove_user_from_task

  post '/sub_events/:id/add_user_to_task', to: 'sub_events#add_user_to_task', as: :add_user_to_task

  devise_for :users, :controllers => { registrations: 'registrations' }

  post '/user_notifications/:id/read_notification', :to => 'user_notification#read_notification', :as => 'read_notification'
  get '/user_notifications/:id/delete_notification', :to => 'user_notification#delete_notification', :as => 'delete_user_notification'

  resources :users do
    resources :volunteer_notes
    resources :notifications
  end

  scope "/admin" do
    resources :users
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
