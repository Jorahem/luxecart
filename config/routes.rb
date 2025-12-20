Rails.application.routes.draw do
  # Devise for user authentication
  devise_for :users
  
  # Root path
  root 'home#index'
  
  # Customer-facing routes
  resources :products, only: [:index, :show] do
    resources :reviews, only: [:create, :destroy]
    collection do
      get :featured
    end
  end
  
  resources :categories, only: [:index, :show]
  resources :brands, only: [:index, :show]
  
  # Cart routes
  resource :cart, only: [:show] do
    post :add_item
    patch :update_item
    delete :remove_item
    delete :clear
  end
  
  # Wishlist routes
  resource :wishlist, only: [:show] do
    post :add_item
    delete :remove_item
  end
  
  # Orders
  resources :orders, only: [:index, :show] do
    member do
      patch :cancel
    end
  end
  
  # Addresses
  resources :addresses do
    member do
      patch :set_default
    end
  end
  
  # Checkout flow
  namespace :checkout do
    get :shipping
    post :update_shipping
    get :payment
    post :process_payment
    get :confirmation
  end
  
  # Search
  get :search, to: 'search#index'
  
  # Admin namespace
  namespace :admin do
    get '/', to: 'dashboard#index', as: 'dashboard'
    
    resources :products do
      member do
        patch :toggle_featured
      end
    end
    
    resources :categories do
      collection do
        post :sort
      end
    end
    
    resources :brands
    
    resources :orders do
      member do
        patch :update_status
        patch :mark_as_shipped
        patch :mark_as_delivered
      end
    end
    
    resources :users do
      member do
        patch :toggle_admin
      end
    end
    
    resources :coupons do
      member do
        patch :toggle_active
      end
    end
    
    resources :reviews do
      member do
        patch :approve
        patch :reject
      end
    end
    
    resources :addresses, only: [:index, :show, :destroy]
  end
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
