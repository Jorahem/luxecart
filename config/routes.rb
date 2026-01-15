# config/routes.rb
Rails.application.routes.draw do
  # -------------------------
  # Authentication
  # -------------------------
  # Devise for user authentication (single declaration)
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

  # -------------------------
  # Cart (single resource)
  # -------------------------
  # Uses resource :cart (singular) to map to /cart
  resource :cart, only: [:show], controller: 'carts' do
    collection do
      post   :add_item           # POST /cart/add_item
      patch  'update_item/:id', action: :update_item, as: :update_item
      delete 'remove_item/:id', action: :remove_item, as: :remove_item
      delete :clear              # DELETE /cart/clear
      get    :summary            # GET /cart/summary (HTML/JSON)
    end
  end

  # Also provide a dedicated JSON-only summary route (convenience)
  get '/cart/summary', to: 'carts#summary', as: :cart_summary, defaults: { format: :json }

  # Wishlist
  resource :wishlist, only: [:show] do
    post :add_item
    delete :remove_item
  end

  # Orders (customer side)
  # New + Create + Show for checkout flow; index for user order history
  resources :orders, only: [:index, :new, :create, :show] do
    member do
      patch :cancel
    end
  end

  # Addresses (user-managed addresses)
  resources :addresses do
    member do
      patch :set_default
    end
  end

  # -------------------------
  # Static & utility routes
  # -------------------------
  # Search
  get :search, to: 'search#index'

  # Static pages
  get '/about',   to: 'pages#about',   as: :about
  get '/contact', to: 'pages#contact', as: :contact
  post '/contact_submit', to: 'pages#contact_submit', as: :contact_submit
  get '/privacy', to: 'pages#privacy', as: :privacy
  get '/terms',   to: 'pages#terms',   as: :terms

  # -------------------------
  # Admin namespace (controllers under AdminPanel::)
  # -------------------------
  namespace :admin_panel, path: '/admin', as: :admin do
    # Admin auth
    get    'login',  to: 'sessions#new',     as: :login
    post   'login',  to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy', as: :logout

    # Dashboard
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#index', as: :dashboard

    # Realtime JSON endpoint for dashboard
    get 'realtime', to: 'realtime#index', as: :realtime, defaults: { format: :json }

    # Admin resources
    resources :products do
      member do
        patch :toggle_featured
      end
    end

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

    resources :payments, only: [:index, :show]
    resources :reports, only: [:index]
    resource  :settings, only: [:show, :update]

    resources :categories do
      collection do
        post :sort
      end
    end

    resources :brands
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

  # -------------------------
  # Health check
  # -------------------------
  get 'up' => 'rails/health#show', as: :rails_health_check
end