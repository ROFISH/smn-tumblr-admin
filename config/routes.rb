Rails.application.routes.draw do
  get 'main/index'

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

  resources :users

  get 'auth/fangamer/callback' => 'main#fangamer_callback'
  get 'auth/tumblr/callback' => 'main#tumblr_callback'
  get 'main/index'

  get 'queued' => 'main#queued'
  get 'submissions' => 'main#submissions'
  get 'tagged/:tag' => 'main#tagged', format:false, :constraints => { :tag => /.*/ }
  get 'tagged' => 'main#tagged'


  get 'edit/:state/:id' => 'main#edit'
  post 'update/:state/:id' => 'main#update'
  delete 'destroy/:state/:id' => 'main#destroy'

  get 'requeue/:id' => 'main#requeue'
  get 'add_to_queue/:id' => 'main#add_to_queue'
  post 'reblog' => 'main#reblog'
  
  root 'main#index'
end
