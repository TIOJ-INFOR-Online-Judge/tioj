Rails.application.routes.draw do
  resources :announcements

  devise_for :users, controllers: {registrations: "registrations", passwords: "users/passwords"}
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
      get 'raw', to: 'submissions#download_raw'
      get 'old', to: 'submissions#show_old' if Rails.configuration.x.settings.dig(:old_submission_views)
    end
  end

  resources :posts do
    resources :comments, except: [:index]
  end

  resources :contests do
    resources :submissions do
      get 'raw', to: 'submissions#download_raw', on: :member
    end
    resources :problems, except: [:index, :create, :new] do
      resources :submissions, only: [:index, :create, :new]
    end
    resources :announcements
    resources :posts do
      resources :comments, except: [:index]
    end

    resources :contest_registrations, only: [:index, :new, :create, :destroy] do
      collection do
        get 'batch_new'
        post 'batch_new', to: 'contest_registrations#batch_create'
        post 'batch_delete'
      end
    end

    member do
      post 'set_contest_task'
      post 'register'
      get 'dashboard'
      get 'dashboard_update'
    end
  end

  resources :contests, only: [:show], as: :single_contest, path: '/single_contest' do
    resources :submissions, only: [:index, :create, :new, :show] do
      get 'raw', to: 'submissions#download_raw', on: :member
    end
    resources :problems, only: [:show] do
      resources :submissions, only: [:index, :create, :new]
    end
    resources :posts, only: [:index, :create, :new]

    member do
      get 'dashboard'
      get 'dashboard_update'
      # custom user session
      get 'users/sign_in', as: :sign_in, to: 'contests#sign_in'
      post 'users/sign_in', as: :sign_in_post, to: 'contests#sign_in_post'
      delete 'users/sign_out', as: :sign_out, to: 'contests#sign_out'
    end
  end

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

  get 'problems/:id/*file' => redirect{ |path, req| "/#{path[:file]}"}, format: false, id: /[0-9]+/
  get 'problems/*file' => redirect{ |path, req| "/#{path[:file]}"}, format: false
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
