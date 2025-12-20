Rails.application.routes.draw do
  # Devise routes for authentication
  devise_for :users

  # Root path
  root "home#index"

  # Static pages
  get "about", to: "home#about"
  get "contact", to: "home#contact"

  # Products routes with search and filters
  resources :products, only: [:index, :show] do
    collection do
      get :search
    end
    member do
      post :add_to_cart
    end
    resources :reviews, only: [:create, :destroy]
  end

  # Categories
  resources :categories, only: [:index, :show]

  # Brands
  resources :brands, only: [:index, :show]

  # Cart operations
  resource :cart, only: [:show] do
    post :add_item
    patch :update_item
    delete :remove_item
    delete :clear
  end

  # Wishlist
  resource :wishlist, only: [:show] do
    post :add_item
    delete :remove_item
  end

  # Checkout process
  resource :checkout, only: [:show, :create] do
    get :success
    get :cancel
  end

  # Orders
  resources :orders, only: [:index, :show] do
    member do
      post :cancel
    end
  end

  # User addresses
  resources :addresses do
    member do
      post :set_default
    end
  end

  # Admin namespace
  namespace :admin do
    root "dashboard#index"
    
    resources :dashboard, only: [:index]
    
    resources :products do
      member do
        post :toggle_featured
      end
    end
    
    resources :orders do
      member do
        patch :update_status
      end
    end
    
    resources :categories
    resources :brands
    resources :users do
      member do
        post :toggle_admin
      end
    end
    
    resources :reviews do
      member do
        post :approve
        post :reject
      end
    end
    
    resources :coupons
  end

  # API namespace
  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :show]
      resources :categories, only: [:index, :show]
      resources :brands, only: [:index, :show]
      
      resource :cart, only: [:show, :create] do
        post :add_item
        patch :update_item
        delete :remove_item
      end
      
      resources :orders, only: [:index, :show, :create]
      
      post "auth/login", to: "authentication#login"
      post "auth/register", to: "authentication#register"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
