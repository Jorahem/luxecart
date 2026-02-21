Rails.application.routes.draw do
  # -------------------------
  # Authentication
  # -------------------------
  devise_for :users, controllers: { registrations: "registrations" }

  # -------------------------
  # Public / Customer-facing
  # -------------------------
  root "home#index"

  # Products + reviews + featured + like/unlike
  resources :products, only: %i[index show] do
    resources :reviews, only: %i[create destroy]

    collection do
      get :featured
    end

    member do
      post :like, to: "likes#create"
      delete :like, to: "likes#destroy"
    end
  end

  # Categories & Brands (public)
  resources :categories, only: %i[index show]
  resources :brands, only: %i[index show]

  resource :profile, only: %i[show update]

  # -------------------------
  # Cart
  # -------------------------
  get    "/cart",                 to: "carts#show",        as: :cart
  post   "/cart/add_item",        to: "cart_items#create", as: :cart_add_item
  patch  "/cart/update_item/:id", to: "carts#update_item", as: :cart_update_item
  delete "/cart/remove_item/:id", to: "carts#remove_item", as: :cart_remove_item
  delete "/cart/clear",           to: "carts#clear",       as: :cart_clear

  get "/cart/summary", to: "carts#summary", as: :cart_summary, defaults: { format: :json }

  # keep this redirect from your old file
  get "/cart/add_item", to: redirect("/cart")

  # -------------------------
  # Wishlist
  # -------------------------
  resource :wishlist, only: %i[show] do
    post :add_item
    delete :remove_item
  end

  # -------------------------
  # Orders (customer/checkout)
  # -------------------------
  resources :orders, only: %i[index new create show] do
    member do
      patch :cancel
      patch :mark_received
    end
  end
  get "/checkout", to: "orders#new", as: :checkout

  # -------------------------
  # Addresses (user-managed)
  # -------------------------
  resources :addresses do
    member do
      patch :set_default
    end
  end

  # -------------------------
  # Static & utility routes
  # -------------------------
  get :search, to: "search#index"

  get  "/about",   to: "pages#about",   as: :about
  get  "/contact", to: "pages#contact", as: :contact
  post "/contact_submit", to: "pages#contact_submit", as: :contact_submit
  get  "/privacy", to: "pages#privacy", as: :privacy
  get  "/terms",   to: "pages#terms",   as: :terms

  # -------------------------
  # Public contact messages
  # -------------------------
  resources :contact_messages, only: %i[new create]

  # -------------------------
  # Admin namespace (controllers under AdminPanel::)
  # URL prefix: /admin
  # Named routes: admin_*
  # -------------------------
  namespace :admin_panel, path: "/admin", as: :admin do
    # Auth
    get    "login",  to: "sessions#new",     as: :login
    post   "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy", as: :logout

    # Dashboard
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index", as: :dashboard

    # Optional dashboard JSON endpoints
    get "dashboard/summary",  to: "dashboard#summary",  as: :dashboard_summary,  defaults: { format: :json }
    get "dashboard/activity", to: "dashboard#activity", as: :dashboard_activity, defaults: { format: :json }

    # Admin resources
    resources :products do
      member do
        patch :toggle_featured
        patch :adjust_stock
      end
    end

    resources :orders do
      member do
        patch :update_status
        patch :mark_as_shipped
        patch :mark_as_delivered
        patch :mark_as_paid
      end
    end

    resources :users do
      member do
        patch :toggle_admin
      end
    end

    resources :payments, only: %i[index show]
    resources :reports,  only: %i[index]
    resource  :settings, only: %i[show update]

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

    resources :addresses, only: %i[index show destroy]

    # Admin Contact Messages
    # /admin/contact_messages
    resources :contact_messages, only: %i[index show] do
      member do
        patch :mark_read
        patch :reply
      end
    end
  end

  # -------------------------
  # Health check
  # -------------------------
  get "up" => "rails/health#show", as: :rails_health_check
end