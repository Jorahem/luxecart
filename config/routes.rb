Rails.application.routes.draw do
  devise_for :users
  
  root 'home#index'
  
  # Customer-facing routes
  resources :products, only: [:index, :show] do
    resources :reviews, only: [:create]
    collection do
      get :featured
    end
  end
  
  resources :categories, only: [:index, :show]
  resources :brands, only: [:index, :show]
  resource :cart, only: [:show]
  resources :cart_items, only: [:create, :update, :destroy]
  resource :wishlist, only: [:show]
  resources :wishlist_items, only: [:create, :destroy]
  resources :orders, only: [:index, :show] do
    member do
      patch :cancel
    end
  end
  resources :addresses
  
  # Checkout flow
  get 'checkout', to: 'checkout#new', as: :new_checkout
  post 'checkout', to: 'checkout#create', as: :checkout
  
  # Search
  get 'search', to: 'search#index'
  
  # Admin namespace
  namespace :admin do
    get '/', to: 'dashboard#index', as: 'dashboard'
    resources :products
    resources :categories
    resources :brands
    resources :orders do
      member do
        patch :update_status
      end
    end
    resources :users
    resources :coupons
    resources :reviews do
      member do
        patch :approve
        patch :reject
      end
    end
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
