# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create Admin User
admin = User.find_or_create_by!(email: ENV.fetch('ADMIN_EMAIL', 'admin@luxecart.com')) do |user|
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.password = ENV.fetch('ADMIN_PASSWORD', 'Password123!')
  user.password_confirmation = ENV.fetch('ADMIN_PASSWORD', 'Password123!')
  user.role = 'admin'
end
puts "✅ Admin user created: #{admin.email}"

# Create Sample Users
5.times do |i|
  User.find_or_create_by!(email: "user#{i+1}@example.com") do |user|
    user.first_name = "User"
    user.last_name = "#{i+1}"
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.role = 'customer'
  end
end
puts "✅ Created 5 sample users"

# Create Brands
brands_data = [
  { name: 'Apple', description: 'Premium technology products', website: 'https://www.apple.com' },
  { name: 'Samsung', description: 'Electronics and appliances', website: 'https://www.samsung.com' },
  { name: 'Nike', description: 'Sports apparel and footwear', website: 'https://www.nike.com' },
  { name: 'Adidas', description: 'Athletic shoes and clothing', website: 'https://www.adidas.com' },
  { name: 'Sony', description: 'Electronics and gaming', website: 'https://www.sony.com' },
  { name: 'LG', description: 'Home appliances and electronics', website: 'https://www.lg.com' },
  { name: 'Canon', description: 'Cameras and imaging products', website: 'https://www.canon.com' },
  { name: 'Dell', description: 'Computers and technology', website: 'https://www.dell.com' }
]

brands = brands_data.map do |brand_data|
  Brand.find_or_create_by!(name: brand_data[:name]) do |brand|
    brand.description = brand_data[:description]
    brand.website = brand_data[:website] if brand_data[:website]
    brand.active = true
  end
end
puts "✅ Created #{brands.count} brands"

# Create Categories
electronics = Category.find_or_create_by!(name: 'Electronics') do |cat|
  cat.description = 'Electronic devices and gadgets'
  cat.active = true
end

clothing = Category.find_or_create_by!(name: 'Clothing') do |cat|
  cat.description = 'Apparel and fashion'
  cat.active = true
end

home = Category.find_or_create_by!(name: 'Home & Garden') do |cat|
  cat.description = 'Home improvement and garden supplies'
  cat.active = true
end

sports = Category.find_or_create_by!(name: 'Sports & Outdoors') do |cat|
  cat.description = 'Sports equipment and outdoor gear'
  cat.active = true
end

# Create subcategories
Category.find_or_create_by!(name: 'Smartphones', parent: electronics) do |cat|
  cat.description = 'Mobile phones and accessories'
  cat.active = true
end

Category.find_or_create_by!(name: 'Laptops', parent: electronics) do |cat|
  cat.description = 'Portable computers'
  cat.active = true
end

Category.find_or_create_by!(name: "Men's Clothing", parent: clothing) do |cat|
  cat.description = "Men's apparel"
  cat.active = true
end

Category.find_or_create_by!(name: "Women's Clothing", parent: clothing) do |cat|
  cat.description = "Women's apparel"
  cat.active = true
end

puts "✅ Created categories and subcategories"

# Create Products
products_data = [
  { name: 'iPhone 15 Pro', description: 'Latest Apple smartphone with advanced features', price: 999.99, compare_price: 1099.99, brand: 'Apple', category: 'Smartphones', stock: 50, featured: true },
  { name: 'Samsung Galaxy S24', description: 'Premium Android smartphone', price: 899.99, brand: 'Samsung', category: 'Smartphones', stock: 45, featured: true },
  { name: 'MacBook Air M3', description: 'Lightweight laptop with powerful performance', price: 1299.99, brand: 'Apple', category: 'Laptops', stock: 30, featured: true },
  { name: 'Dell XPS 15', description: 'High-performance laptop for professionals', price: 1499.99, compare_price: 1699.99, brand: 'Dell', category: 'Laptops', stock: 25 },
  { name: 'Nike Air Max', description: 'Comfortable running shoes', price: 129.99, brand: 'Nike', category: 'Sports & Outdoors', stock: 100 },
  { name: 'Adidas Ultraboost', description: 'Premium running shoes', price: 179.99, compare_price: 199.99, brand: 'Adidas', category: 'Sports & Outdoors', stock: 80 },
  { name: 'Sony WH-1000XM5', description: 'Noise-cancelling headphones', price: 399.99, brand: 'Sony', category: 'Electronics', stock: 60, featured: true },
  { name: 'Canon EOS R6', description: 'Professional mirrorless camera', price: 2499.99, brand: 'Canon', category: 'Electronics', stock: 15 },
  { name: 'LG OLED TV 65"', description: 'Premium 4K OLED television', price: 1999.99, compare_price: 2299.99, brand: 'LG', category: 'Electronics', stock: 20 },
  { name: 'Nike Pro Shorts', description: 'Athletic shorts for training', price: 29.99, brand: 'Nike', category: "Men's Clothing", stock: 150 }
]

products_data.each do |product_data|
  brand = Brand.find_by(name: product_data[:brand])
  category = Category.find_by(name: product_data[:category])
  
  Product.find_or_create_by!(
    name: product_data[:name]
  ) do |product|
    product.description = product_data[:description]
    product.price = product_data[:price]
    product.compare_price = product_data[:compare_price]
    product.sku = "SKU-#{SecureRandom.hex(4).upcase}"
    product.stock_quantity = product_data[:stock]
    product.brand = brand
    product.category = category
    product.status = :active
    product.featured = product_data[:featured] || false
    product.sales_count = rand(0..100)
    product.views_count = rand(100..1000)
  end
end
puts "✅ Created #{products_data.count} products"

# Create Coupons
Coupon.find_or_create_by!(code: 'WELCOME10') do |coupon|
  coupon.discount_type = :percentage
  coupon.discount_value = 10
  coupon.minimum_order_value = 50
  coupon.description = 'Welcome discount for new customers'
  coupon.active = true
end

Coupon.find_or_create_by!(code: 'SAVE20') do |coupon|
  coupon.discount_type = :fixed_amount
  coupon.discount_value = 20
  coupon.minimum_order_value = 100
  coupon.description = '$20 off orders over $100'
  coupon.active = true
end

Coupon.find_or_create_by!(code: 'FREESHIP') do |coupon|
  coupon.discount_type = :fixed_amount
  coupon.discount_value = 9.99
  coupon.minimum_order_value = 75
  coupon.description = 'Free shipping on orders over $75'
  coupon.active = true
end

puts "✅ Created 3 coupons"

# Create Reviews for some products
User.where(role: 'customer').each do |user|
  Product.limit(3).each do |product|
    Review.find_or_create_by!(user: user, product: product) do |review|
      review.rating = rand(3..5)
      review.title = ["Great product!", "Love it!", "Excellent quality", "Good value"].sample
      review.comment = "This is a sample review for #{product.name}. #{['Highly recommended!', 'Would buy again.', 'Good quality.'].sample}"
      review.status = :approved
      review.verified_purchase = [true, false].sample
    end
  rescue ActiveRecord::RecordInvalid
    # Skip if user already reviewed this product
  end
end
puts "✅ Created sample reviews"

puts "✅ Database seeding completed!"
puts ""
puts "Admin Login:"
puts "  Email: #{admin.email}"
puts "  Password: #{ENV.fetch('ADMIN_PASSWORD', 'Password123!')}"
puts ""
puts "Sample User Login:"
puts "  Email: user1@example.com"
puts "  Password: password123"

