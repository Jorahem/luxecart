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

  # Static / simple pages
  # About, contact, privacy and terms (named routes used by footer and layouts)
  get '/about',   to: 'pages#about',   as: :about
  get '/contact', to: 'pages#contact', as: :contact
  post '/contact_submit', to: 'pages#contact_submit', as: :contact_submit
  get '/privacy', to: 'pages#privacy', as: :privacy
  get '/terms',   to: 'pages#terms',   as: :terms
  
  # Admin namespace
  namespace :admin do
    get '/', to: 'dashboard#index', as: 'dashboard'
    
    resources :products do
      member do
        patch :toggle_featured
      end
    end
    




# ... earlier routes remain unchanged ...

resources :products, only: [:index, :show] do
  resources :reviews, only: [:create, :destroy]
  collection do
    get :featured
  end

  # member routes for server-backed likes (POST to like, DELETE to unlike)
  member do
    post :like, to: 'likes#create'
    delete :like, to: 'likes#destroy'
  end
end

# ... rest of routes remain unchanged ...








  resource :cart, only: [:show] do
    post 'add_item', to: 'carts#add_item'
    delete 'remove_item/:id', to: 'carts#remove_item', as: 'remove_item'
  end






resource :cart, only: [:show]


devise_for :users, controllers: { registrations: 'registrations' }

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