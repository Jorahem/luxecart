puts "🌱 Seeding database..."

# Clear existing data
puts "Clearing existing data..."
Review.destroy_all
OrderItem.destroy_all
Order.destroy_all
CartItem.destroy_all
Cart.destroy_all
WishlistItem.destroy_all
Wishlist.destroy_all
Address.destroy_all
Product.destroy_all
Category.destroy_all
Brand.destroy_all
User.destroy_all

puts "✅ Data cleared"

# Create admin user
puts "Creating admin user..."
admin = User.create!(
  email: 'admin@luxecart.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: :admin
)
puts "✅ Admin created: admin@luxecart.com / password123"

# Create customer users
puts "Creating customer users..."
5.times do |i|
  User.create!(
    email: "customer#{i+1}@example.com",
    password: 'password123',
    password_confirmation: 'password123',
    first_name: "Customer",
    last_name: "#{i+1}",
    role: :customer
  )
end
puts "✅ 5 customers created"

# Create Brands
puts "Creating brands..."
brands_data = [
  { name: 'Apple', description: 'Premium electronics and technology' },
  { name: 'Samsung', description: 'Innovative electronics and appliances' },
  { name: 'Nike', description: 'Athletic footwear and apparel' },
  { name: 'Adidas', description: 'Sports and lifestyle products' },
  { name: 'Sony', description: 'Electronics and entertainment' },
  { name: 'LG', description: 'Home appliances and electronics' },
  { name: 'Dell', description: 'Computers and technology solutions' },
  { name: 'HP', description: 'Computing and printing solutions' }
]

brands = brands_data.map do |data|
  Brand.create!(
    name: data[:name],
    description: data[:description],
    active: true
  )
end
puts "✅ #{brands.count} brands created"

# Create Categories
puts "Creating categories..."
electronics = Category.create!(name: 'Electronics', description: 'Electronic devices and gadgets', active: true)
phones = Category.create!(name: 'Smartphones', description: 'Mobile phones and accessories', active: true, parent_id: electronics.id)
laptops = Category.create!(name: 'Laptops', description: 'Portable computers', active: true, parent_id: electronics.id)

clothing = Category.create!(name: 'Clothing', description: 'Apparel and fashion', active: true)
mens = Category.create!(name: "Men's Wear", description: 'Clothing for men', active: true, parent_id: clothing.id)
womens = Category.create!(name: "Women's Wear", description: 'Clothing for women', active: true, parent_id: clothing.id)

sports = Category.create!(name: 'Sports & Outdoors', description: 'Sports equipment and outdoor gear', active: true)
puts "✅ #{Category.count} categories created"

# Create Products
puts "Creating products..."
products_data = [
  { name: 'iPhone 15 Pro', description: 'Latest Apple smartphone with A17 Pro chip', price: 999.99, category: phones, brand: brands[0], stock: 50 },
  { name: 'Samsung Galaxy S24', description: 'Flagship Android smartphone', price: 899.99, compare_price: 799.99, category: phones, brand: brands[1], stock: 45 },
  { name: 'MacBook Air M3', description: '13-inch laptop with M3 chip', price: 1299.99, category: laptops, brand: brands[0], stock: 30 },
  { name: 'Dell XPS 15', description: 'Premium Windows laptop', price: 1499.99, compare_price: 1299.99, category: laptops, brand: brands[6], stock: 25 },
  { name: 'Nike Air Max', description: 'Comfortable running shoes', price: 129.99, category: sports, brand: brands[2], stock: 100 },
  { name: 'Adidas Ultraboost', description: 'Premium running shoes', price: 180.00, compare_price: 149.99, category: sports, brand: brands[3], stock: 75 },
  { name: 'Sony WH-1000XM5', description: 'Noise-canceling headphones', price: 399.99, category: electronics, brand: brands[4], stock: 60 },
  { name: 'LG OLED TV 55"', description: '4K OLED Smart TV', price: 1799.99, category: electronics, brand: brands[5], stock: 15 },
  { name: 'HP Laptop 14"', description: 'Affordable Windows laptop', price: 549.99, category: laptops, brand: brands[7], stock: 40 },
  { name: 'Samsung Galaxy Tab', description: 'Android tablet', price: 449.99, category: electronics, brand: brands[1], stock: 35 }
]

products = products_data.map do |data|
  Product.create!(
    name: data[:name],
    description: data[:description],
    price: data[:price],
    compare_price: data[:compare_price],
    sku: "SKU-#{rand(10000..99999)}",
    stock_quantity: data[:stock],
    category: data[:category],
    brand: data[:brand],
    status: :active,
    featured: [true, false].sample
  )
end
puts "✅ #{products.count} products created"

# Create sample orders
puts "Creating sample orders..."
customers = User.where(role: :customer)
customers.first(3).each do |customer|
  order = Order.create!(
    user: customer,
    order_number: "ORD-#{rand(100000..999999)}",
    status: [:pending, :processing, :shipped, :delivered].sample,
    payment_status: :paid,
    payment_method: 'stripe',
    total_price: 0
  )
  
  # Add 2-3 random products to each order
  total = 0
  rand(2..3).times do
    product = products.sample
    quantity = rand(1..3)
    unit_price = product.price
    item_total = unit_price * quantity
    total += item_total
    
    OrderItem.create!(
      order: order,
      product: product,
      quantity: quantity,
      unit_price: unit_price,
      total_price: item_total,
      product_name: product.name,
      product_sku: product.sku
    )
  end
  
  order.update!(total_price: total, subtotal: total)
end
puts "✅ Sample orders created"

# Create sample reviews
puts "Creating sample reviews..."
products.first(5).each do |product|
  customers.first(3).each do |customer|
    Review.create!(
      user: customer,
      product: product,
      rating: rand(3..5),
      title: "Great product!",
      comment: "I really enjoyed using this product. Highly recommended!",
      status: :approved
    )
  end
end
puts "✅ Sample reviews created"

puts "\n🎉 Database seeded successfully!"
puts "\n📊 Summary:"
puts "  Users: #{User.count} (1 admin, #{User.where(role: :customer).count} customers)"
puts "  Brands: #{Brand.count}"
puts "  Categories: #{Category.count}"
puts "  Products: #{Product.count}"
puts "  Orders: #{Order.count}"
puts "  Reviews: #{Review.count}"
puts "\n🔐 Admin Login:"
puts "  Email: admin@luxecart.com"
puts "  Password: password123"
