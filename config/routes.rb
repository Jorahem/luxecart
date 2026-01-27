Rails.application.routes.draw do
  # -------------------------
  # Authentication
  # -------------------------
  # Devise for user authentication
  devise_for :users, controllers: { registrations: 'registrations' }

  # -------------------------
  # Public / Customer-facing
  # -------------------------
  root 'home#index'

  # Products + reviews + featured + like/unlike
  resources :products, only: [:index, :show] do
    resources :reviews, only: [:create, :destroy]
    collection do
      get :featured
    end
    member do
      post :like, to: 'likes#create'
      delete :like, to: 'likes#destroy'
    end
  end

  # Categories & Brands (public)
  resources :categories, only: [:index, :show]
  resources :brands, only: [:index, :show]

  resource :profile, only: [:show, :update] 

  # -------------------------
  # Cart (explicit, single resource routes)
  # -------------------------
  get    '/cart',                   to: 'carts#show',        as: :cart
  post   '/cart/add_item',          to: 'cart_items#create', as: :cart_add_item
  patch  '/cart/update_item/:id',   to: 'carts#update_item', as: :cart_update_item
  delete '/cart/remove_item/:id',   to: 'carts#remove_item', as: :cart_remove_item
  delete '/cart/clear',             to: 'carts#clear',       as: :cart_clear
  get    '/cart/summary',           to: 'carts#summary',     as: :cart_summary, defaults: { format: :json }
  get    '/cart/add_item',          to: redirect('/cart')

  # -------------------------
  # Wishlist
  # -------------------------
  resource :wishlist, only: [:show] do
    post :add_item
    delete :remove_item
  end

  # Orders (customer/checkout)
  resources :orders, only: [:index, :new, :create, :show] do
    member do
      patch :cancel
    end
  end
  get '/checkout', to: 'orders#new', as: :checkout

  # Addresses (user-managed)
  resources :addresses do
    member do
      patch :set_default
    end
  end

  # -------------------------
  # Static & utility routes
  # -------------------------
  get :search, to: 'search#index'

  get '/about',   to: 'pages#about',   as: :about
  get '/contact', to: 'pages#contact', as: :contact
  post '/contact_submit', to: 'pages#contact_submit', as: :contact_submit
  get '/privacy', to: 'pages#privacy', as: :privacy
  get '/terms',   to: 'pages#terms',   as: :terms

  # -------------------------
  # Admin namespace (controllers under Admin::)


  namespace :admin_panel, path: '/admin', as: :admin do
  get    'login',  to: 'sessions#new',     as: :login
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: :logout
  root to: 'dashboard#index'
  get 'dashboard', to: 'dashboard#index', as: :dashboard
  ...
end
  # -------------------------
  namespace :admin do
    root "dashboard#index", as: :dashboard
    resources :products do
      member do
        patch :toggle_active
      end
    end
    resources :categories
    resources :orders do
      collection do
        get :export
      end
    end
    resources :users do
      member do
        patch :block
        patch :unblock
        patch :make_admin
        patch :revoke_admin
      end
    end
    get "reports", to: "reports#index"
    # Add further analytics endpoints as required (e.g. GET /admin/reports/top_products)
  end

  # -------------------------
  # Health check
  # -------------------------
  get 'up' => 'rails/health#show', as: :rails_health_check
end
