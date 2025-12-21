# Clear existing data in development
if Rails.env.development?
  puts "Clearing existing data..."
  OrderItem.destroy_all
  Order.destroy_all
  CartItem.destroy_all
  Cart.destroy_all
  Review.destroy_all
  Product.destroy_all
  Category.destroy_all
  Brand.destroy_all
  User.destroy_all
end

puts "Creating admin user..."
admin = User.create!(
  email: 'admin@luxecart.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  phone: '+1 (555) 000-0000',
  role: User::ROLE_ADMIN
)

puts "Creating regular user..."
user = User.create!(
  email: 'user@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'John',
  last_name: 'Doe',
  phone: '+1 (555) 123-4567',
  role: User::ROLE_CUSTOMER
)

puts "Creating categories..."
electronics = Category.create!(name: 'Electronics', description: 'Gadgets and electronic devices', active: true, position: 1)
clothing = Category.create!(name: 'Clothing', description: 'Fashion and apparel', active: true, position: 2)
home = Category.create!(name: 'Home & Garden', description: 'Home improvement and garden supplies', active: true, position: 3)
sports = Category.create!(name: 'Sports & Outdoors', description: 'Sports equipment and outdoor gear', active: true, position: 4)
books = Category.create!(name: 'Books', description: 'Books and reading materials', active: true, position: 5)

puts "Creating brands..."
apple = Brand.create!(name: 'Apple', description: 'Premium technology products', website: 'https://apple.com', active: true)
nike = Brand.create!(name: 'Nike', description: 'Athletic footwear and apparel', website: 'https://nike.com', active: true)
samsung = Brand.create!(name: 'Samsung', description: 'Electronics and appliances', website: 'https://samsung.com', active: true)
adidas = Brand.create!(name: 'Adidas', description: 'Sports clothing and accessories', website: 'https://adidas.com', active: true)
generic = Brand.create!(name: 'Generic Brand', description: 'Quality products at great prices', active: true)

puts "Creating products..."

# Electronics
Product.create!([
  {
    name: 'iPhone 15 Pro',
    description: 'Latest flagship smartphone from Apple with A17 Pro chip, titanium design, and advanced camera system.',
    price: 999.99,
    compare_price: 1099.99,
    sku: 'IPHONE15PRO',
    stock_quantity: 50,
    category: electronics,
    brand: apple,
    status: 1,
    featured: true
  },
  {
    name: 'Samsung Galaxy S24',
    description: 'Premium Android smartphone with cutting-edge display and camera technology.',
    price: 899.99,
    compare_price: 999.99,
    sku: 'GALAXYS24',
    stock_quantity: 35,
    category: electronics,
    brand: samsung,
    status: 1,
    featured: true
  },
  {
    name: 'Wireless Earbuds Pro',
    description: 'High-quality wireless earbuds with active noise cancellation and premium sound.',
    price: 179.99,
    sku: 'EARBUDSPRO',
    stock_quantity: 100,
    category: electronics,
    brand: apple,
    status: 1,
    featured: true
  }
])

# Clothing
Product.create!([
  {
    name: 'Classic Running Shoes',
    description: 'Comfortable and durable running shoes perfect for daily workouts.',
    price: 89.99,
    compare_price: 119.99,
    sku: 'RUNSHOE01',
    stock_quantity: 75,
    category: clothing,
    brand: nike,
    status: 1,
    featured: true
  },
  {
    name: 'Performance Athletic Wear Set',
    description: 'Breathable athletic wear designed for peak performance.',
    price: 59.99,
    sku: 'ATHWEAR01',
    stock_quantity: 60,
    category: clothing,
    brand: adidas,
    status: 1
  },
  {
    name: 'Premium Sports Jacket',
    description: 'Weather-resistant sports jacket with modern design.',
    price: 129.99,
    compare_price: 159.99,
    sku: 'SPORTJKT01',
    stock_quantity: 40,
    category: clothing,
    brand: nike,
    status: 1,
    featured: true
  }
])

# Home & Garden
Product.create!([
  {
    name: 'Smart LED Lamp',
    description: 'WiFi-enabled smart lamp with adjustable colors and brightness.',
    price: 49.99,
    sku: 'SMARTLAMP01',
    stock_quantity: 80,
    category: home,
    brand: generic,
    status: 1
  },
  {
    name: 'Garden Tool Set',
    description: 'Complete 10-piece garden tool set for all your gardening needs.',
    price: 79.99,
    sku: 'GARDENTOOL',
    stock_quantity: 45,
    category: home,
    brand: generic,
    status: 1
  }
])

# Sports & Outdoors
Product.create!([
  {
    name: 'Yoga Mat Premium',
    description: 'Extra-thick premium yoga mat with non-slip surface.',
    price: 39.99,
    sku: 'YOGAMAT01',
    stock_quantity: 90,
    category: sports,
    brand: adidas,
    status: 1,
    featured: true
  },
  {
    name: 'Camping Backpack',
    description: '50L waterproof camping backpack with multiple compartments.',
    price: 89.99,
    compare_price: 109.99,
    sku: 'CAMPBACK01',
    stock_quantity: 30,
    category: sports,
    brand: generic,
    status: 1
  }
])

# Books
Product.create!([
  {
    name: 'The Art of Programming',
    description: 'Comprehensive guide to modern software development practices.',
    price: 49.99,
    sku: 'BOOKPROG01',
    stock_quantity: 120,
    category: books,
    brand: generic,
    status: 1
  },
  {
    name: 'Mindfulness for Beginners',
    description: 'Learn the basics of mindfulness and meditation.',
    price: 19.99,
    sku: 'BOOKMIND01',
    stock_quantity: 85,
    category: books,
    brand: generic,
    status: 1,
    featured: true
  }
])

puts "Creating sample order..."
order = user.orders.create!(
  order_number: "ORD-#{Time.current.strftime('%Y%m%d')}-TEST01",
  subtotal: 1259.96,
  tax_amount: 125.99,
  shipping_cost: 9.99,
  discount_amount: 0,
  total_price: 1395.94,
  status: 1,
  payment_status: 1,
  payment_method: 'cash_on_delivery'
)

order.order_items.create!([
  {
    product: Product.find_by(sku: 'IPHONE15PRO'),
    quantity: 1,
    unit_price: 999.99,
    total_price: 999.99,
    product_name: 'iPhone 15 Pro',
    product_sku: 'IPHONE15PRO'
  },
  {
    product: Product.find_by(sku: 'RUNSHOE01'),
    quantity: 2,
    unit_price: 89.99,
    total_price: 179.98,
    product_name: 'Classic Running Shoes',
    product_sku: 'RUNSHOE01'
  },
  {
    product: Product.find_by(sku: 'SMARTLAMP01'),
    quantity: 1,
    unit_price: 49.99,
    total_price: 49.99,
    product_name: 'Smart LED Lamp',
    product_sku: 'SMARTLAMP01'
  }
])

puts "Seed data created successfully!"
puts "="*50
puts "Admin credentials:"
puts "  Email: admin@luxecart.com"
puts "  Password: password123"
puts "="*50
puts "User credentials:"
puts "  Email: user@example.com"
puts "  Password: password123"
puts "="*50
puts "Created:"
puts "  - #{User.count} users"
puts "  - #{Category.count} categories"
puts "  - #{Brand.count} brands"
puts "  - #{Product.count} products"
puts "  - #{Order.count} orders with #{OrderItem.count} items"
puts "="*50
