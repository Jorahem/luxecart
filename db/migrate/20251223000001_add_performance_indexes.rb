class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    # Products - most queried table
    add_index :products, [:status, :featured], name: 'index_products_on_status_and_featured'
    add_index :products, [:category_id, :status], name: 'index_products_on_category_and_status'
    add_index :products, [:brand_id, :status], name: 'index_products_on_brand_and_status'
    add_index :products, :created_at, name: 'index_products_on_created_at'
    add_index :products, [:stock_quantity, :status], name: 'index_products_on_stock_and_status'
    
    # Orders - critical for admin and customer views
    add_index :orders, [:user_id, :status], name: 'index_orders_on_user_and_status'
    add_index :orders, [:created_at, :status], name: 'index_orders_on_created_at_and_status'
    add_index :orders, [:payment_status, :status], name: 'index_orders_on_payment_and_status'
    
    # Reviews - for product pages
    add_index :reviews, [:product_id, :status], name: 'index_reviews_on_product_and_status'
    add_index :reviews, [:product_id, :rating], name: 'index_reviews_on_product_and_rating'
    
    # Categories - for navigation
    add_index :categories, [:parent_id, :active], name: 'index_categories_on_parent_and_active'
    add_index :categories, :position, name: 'index_categories_on_position'
  end
end
