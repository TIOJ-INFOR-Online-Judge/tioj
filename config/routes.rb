Rails.application.routes.draw do
  resources :announcements

  devise_for :users, :controllers => {:registrations => "registrations"}
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  #resources :limits
  resources :problems do
    resources :testdata do
      collection do
        get 'batch_edit'
        post 'batch_edit', to: 'testdata#batch_update'
      end
    end
    resources :submissions
    resources :posts do
      resources :comments
    end

    member do
      post 'rejudge'
      post 'delsub', to: 'problems#delete_submissions'
      get 'ranklist'
    end
  end

  resources :judge_servers

  resources :submissions do
    member do
      post 'rejudge'
    end
  end

  resources :users, constraints: { id: /[^\/]+/ }
  resources :posts do
    resources :comments
  end

  resources :contests do
    resources :submissions
    resources :problems
    resources :posts do
      resources :comments
    end

    member do
      post 'set_contest_task'
      get 'dashboard'
      get 'dashboard_update'
    end
  end
  resources :contest_problem_joints

  resources :articles

  resources :users do
    member do
      get 'changed_problems'
      get 'changed_submissions'
    end
  end

  get 'problems/tag/:tag' => 'problems#index', as: :problems_tag

  get 'about/verdicts' => 'about#verdicts'
  get 'about/memory' => 'about#memory'

  get 'fetch/testdata' => 'fetch#testdata'

  mathjax 'mathjax'

  get 'about' => 'about#index', as: :about

  get 'problems/:id/*file' => redirect{ |path, req| "/#{path[:file]}"}, :format => false, :id => /[0-9]+/
  get 'problems/*file' => redirect{ |path, req| "/#{path[:file]}"}, :format => false
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
