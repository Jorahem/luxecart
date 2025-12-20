Rails.application.routes.draw do
  # Devise for user authentication
  devise_for :users

  # Root page
  root "home#index"

  # Static pages
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"

  # Products
  resources :products, only: [:index, :show] do
    collection do
      get :search
    end
    member do
      post :add_to_wishlist
    end
    resources :reviews, only: [:create, :destroy]
  end

  # Categories & Brands
  resources :categories, only: [:index, :show]
  resources :brands, only: [:index, :show]

  # Shopping Cart
  resource :cart, only: [:show] do
    post :add_item
    patch :update_item
    delete :remove_item
    delete :clear
  end

  # Wishlist (requires authentication)
  resource :wishlist, only: [:show] do
    post :add_item
    delete :remove_item
  end

  # Checkout & Orders (requires authentication)
  resources :orders, only: [:index, :show] do
    member do
      patch :cancel
    end
  end

  resource :checkout, only: [:new, :create]

  # User Addresses (requires authentication)
  resources :addresses do
    member do
      patch :set_default
    end
  end

  # Admin Panel (requires admin role)
  namespace :admin do
    root "dashboard#index"
    
    resources :dashboard, only: [:index]
    
    resources :products do
      member do
        patch :toggle_active
        patch :toggle_featured
      end
    end
    
    resources :categories do
      member do
        patch :toggle_active
      end
    end
    
    resources :brands do
      member do
        patch :toggle_active
      end
    end
    
    resources :orders, only: [:index, :show] do
      member do
        patch :update_status
      end
    end
    
    resources :users, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :toggle_admin
      end
    end
    
    resources :reviews, only: [:index, :show, :destroy] do
      member do
        patch :approve
        patch :reject
      end
    end

    resources :coupons
    resources :shipping_methods
  end

  # API endpoints (v1)
  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :show]
      resources :categories, only: [:index, :show]
      resources :brands, only: [:index, :show]
      
      resource :cart, only: [:show, :create, :update, :destroy]
      resources :orders, only: [:index, :show, :create]
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
