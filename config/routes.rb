Rails.application.routes.draw do
  # Root route
  root 'home#index'

  # Devise routes for authentication
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # Customer-facing routes
  resources :products, only: [:index, :show] do
    collection do
      get :search
    end
  end
  
  resources :categories, only: [:index, :show]
  resources :brands, only: [:index, :show]
  
  # Cart routes
  resource :cart, only: [:show] do
    post 'add_item/:product_id', action: :add_item, as: :add_item
    delete 'remove_item/:id', action: :remove_item, as: :remove_item
    patch 'update_quantity/:id', action: :update_quantity, as: :update_quantity
    delete 'clear'
  end

  # Checkout routes
  namespace :checkout do
    get 'shipping', to: 'checkout#shipping'
    post 'shipping', to: 'checkout#save_shipping'
    get 'payment', to: 'checkout#payment'
    post 'payment', to: 'checkout#process_payment'
    get 'confirmation/:order_id', to: 'checkout#confirmation', as: :confirmation
  end

  # Order routes
  resources :orders, only: [:index, :show] do
    member do
      get 'invoice'
      post 'cancel'
    end
  end

  # Review routes
  resources :reviews, only: [:create, :update, :destroy]
  
  # Wishlist routes
  resource :wishlist, only: [:show] do
    post 'add/:product_id', action: :add, as: :add
    delete 'remove/:product_id', action: :remove, as: :remove
  end

  # User account routes
  resource :account, only: [:show, :edit, :update]
  resources :addresses do
    member do
      patch :set_default
    end
  end

  # Search
  get 'search', to: 'search#index'
  get 'search/autocomplete', to: 'search#autocomplete'

  # Admin routes
  namespace :admin do
    root 'dashboard#index'
    
    resources :products do
      collection do
        post 'bulk_actions'
      end
    end
    
    resources :categories do
      post 'reorder', on: :collection
    end
    
    resources :brands
    
    resources :orders, only: [:index, :show, :update] do
      member do
        get 'print_invoice'
        post 'refund'
        patch 'update_status'
      end
    end
    
    resources :users, only: [:index, :show] do
      member do
        patch 'update_role'
        patch 'toggle_status'
      end
    end
    
    resources :coupons
    
    resources :reviews, only: [:index, :show, :destroy] do
      member do
        post 'approve'
        post 'reject'
      end
    end
    
    resource :settings, only: [:edit, :update]
  end

  # API routes
  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :show]
      resource :cart, only: [:show] do
        post 'add_item'
        delete 'remove_item'
        patch 'update_quantity'
      end
      resources :orders, only: [:index, :show, :create]
    end
  end
end