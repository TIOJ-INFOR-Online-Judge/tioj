Rails.application.routes.draw do
  resources :announcements

  devise_for :users, :controllers => {:registrations => "registrations", :passwords => "users/passwords"}
  devise_for :admin_users, ActiveAdmin::Devise.config

  scope 'admin' do
    resources :users, controller: 'admin/users', as: 'admin_users', constraints: { id: /[^\/]+/ }, defaults: { format: :html }, format: false
  end
  ActiveAdmin.routes(self)

  resources :problems do
    resources :testdata do
      collection do
        get 'batch_edit'
        post 'batch_edit', to: 'testdata#batch_update'
      end
    end
    resources :submissions
    resources :posts do
      resources :comments, except: [:index]
    end

    member do
      post 'rejudge'
      post 'delsub', to: 'problems#delete_submissions'
      get 'ranklist'
      get 'ranklist_old' if Rails.configuration.x.settings.dig(:old_submission_views)
    end
  end

  resources :judge_servers

  resources :submissions do
    member do
      post 'rejudge'
      get 'old', to: 'submissions#show_old' if Rails.configuration.x.settings.dig(:old_submission_views)
    end
  end

  resources :posts do
    resources :comments, except: [:index]
  end

  resources :contests do
    resources :submissions
    resources :problems
    resources :announcements
    resources :posts do
      resources :comments, except: [:index]
    end

    member do
      post 'set_contest_task'
      get 'dashboard'
      get 'dashboard_update'
    end
  end
  resources :contest_problem_joints

  resources :articles
  resources :testdata, only: [:show]

  resources :users, constraints: { id: /[^\/]+/ }, defaults: { format: :html }, format: false do
    if Rails.configuration.x.settings.dig(:old_submission_views)
      member do
        get 'changed_problems'
        get 'changed_submissions'
      end
    end
  end

  get 'current_user/:path' => 'users#current', constraints: { path: /.*/ }

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

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
