# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Cleaning database..."
Review.delete_all
OrderItem.delete_all
Order.delete_all
CartItem.delete_all
Cart.delete_all
WishlistItem.delete_all
Wishlist.delete_all
ProductImage.delete_all
ProductVariant.delete_all
Product.delete_all
Category.delete_all
Brand.delete_all
Address.delete_all
Coupon.delete_all
User.delete_all

puts "Creating admin user..."
admin = User.create!(
  email: 'admin@luxecart.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: :admin
)

puts "Creating customer users..."
customer1 = User.create!(
  email: 'customer@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'John',
  last_name: 'Doe',
  role: :customer
)

customer2 = User.create!(
  email: 'jane@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Jane',
  last_name: 'Smith',
  role: :customer
)

puts "Creating categories..."
electronics = Category.create!(name: 'Electronics', description: 'Electronic devices and accessories', active: true)
computers = Category.create!(name: 'Computers & Laptops', description: 'Desktop and laptop computers', parent_id: electronics.id, active: true)
phones = Category.create!(name: 'Smartphones', description: 'Mobile phones and accessories', parent_id: electronics.id, active: true)

clothing = Category.create!(name: 'Clothing', description: 'Fashion and apparel', active: true)
mens_clothing = Category.create!(name: "Men's Clothing", description: 'Clothing for men', parent_id: clothing.id, active: true)
womens_clothing = Category.create!(name: "Women's Clothing", description: 'Clothing for women', parent_id: clothing.id, active: true)

home_garden = Category.create!(name: 'Home & Garden', description: 'Home improvement and garden supplies', active: true)
furniture = Category.create!(name: 'Furniture', description: 'Indoor and outdoor furniture', parent_id: home_garden.id, active: true)

puts "Creating brands..."
apple = Brand.create!(name: 'Apple', description: 'Premium electronics and technology', website: 'https://apple.com', active: true)
samsung = Brand.create!(name: 'Samsung', description: 'Consumer electronics manufacturer', website: 'https://samsung.com', active: true)
nike = Brand.create!(name: 'Nike', description: 'Athletic footwear and apparel', website: 'https://nike.com', active: true)
adidas = Brand.create!(name: 'Adidas', description: 'Sports clothing and accessories', website: 'https://adidas.com', active: true)
ikea = Brand.create!(name: 'IKEA', description: 'Furniture and home accessories', website: 'https://ikea.com', active: true)

puts "Creating products..."
# Electronics Products
product1 = Product.create!(
  name: 'iPhone 15 Pro',
  description: 'The latest iPhone with advanced camera system and A17 Pro chip. Features titanium design, Action button, and USB-C.',
  price: 999.99,
  compare_price: 1099.99,
  sku: 'APPLE-IP15PRO-128',
  stock_quantity: 50,
  category: phones,
  brand: apple,
  status: :active,
  featured: true
)

product2 = Product.create!(
  name: 'MacBook Pro 14"',
  description: 'Powerful laptop with M3 chip, stunning Liquid Retina XDR display, and all-day battery life.',
  price: 1999.99,
  sku: 'APPLE-MBP14-M3',
  stock_quantity: 25,
  category: computers,
  brand: apple,
  status: :active,
  featured: true
)

product3 = Product.create!(
  name: 'Samsung Galaxy S24 Ultra',
  description: 'Premium Android smartphone with S Pen, 200MP camera, and powerful performance.',
  price: 1199.99,
  sku: 'SAMSUNG-S24U-256',
  stock_quantity: 30,
  category: phones,
  brand: samsung,
  status: :active,
  featured: true
)

# Clothing Products
product4 = Product.create!(
  name: 'Nike Air Max 270',
  description: 'Comfortable running shoes with Max Air cushioning for all-day comfort.',
  price: 149.99,
  sku: 'NIKE-AM270-BLK-10',
  stock_quantity: 100,
  category: mens_clothing,
  brand: nike,
  status: :active,
  featured: true
)

product5 = Product.create!(
  name: 'Adidas Ultraboost 22',
  description: 'High-performance running shoes with responsive Boost cushioning.',
  price: 189.99,
  sku: 'ADIDAS-UB22-WHT-9',
  stock_quantity: 75,
  category: mens_clothing,
  brand: adidas,
  status: :active,
  featured: false
)

# Home & Garden Products
product6 = Product.create!(
  name: 'IKEA POÄNG Armchair',
  description: 'Comfortable armchair with timeless design and layer-glued bent birch frame.',
  price: 99.99,
  sku: 'IKEA-POANG-BEIGE',
  stock_quantity: 40,
  category: furniture,
  brand: ikea,
  status: :active,
  featured: true
)

product7 = Product.create!(
  name: 'Samsung 4K Smart TV 55"',
  description: 'Crystal UHD 4K TV with HDR, smart features, and sleek design.',
  price: 599.99,
  sku: 'SAMSUNG-TV55-4K',
  stock_quantity: 20,
  category: electronics,
  brand: samsung,
  status: :active,
  featured: false
)

product8 = Product.create!(
  name: 'Nike Dri-FIT Training Shirt',
  description: 'Moisture-wicking training shirt designed for comfort during workouts.',
  price: 29.99,
  sku: 'NIKE-DFIT-SHIRT-M',
  stock_quantity: 200,
  category: mens_clothing,
  brand: nike,
  status: :active,
  featured: false
)

puts "Creating coupons..."
Coupon.create!(
  code: 'WELCOME10',
  discount_type: :percentage,
  discount_value: 10,
  minimum_order_value: 50,
  max_uses: 100,
  current_uses: 0,
  valid_from: Time.current,
  valid_until: 3.months.from_now,
  active: true,
  description: 'Get 10% off your first order over $50'
)

Coupon.create!(
  code: 'SAVE20',
  discount_type: :fixed_amount,
  discount_value: 20,
  minimum_order_value: 100,
  max_uses: 50,
  current_uses: 0,
  valid_from: Time.current,
  valid_until: 1.month.from_now,
  active: true,
  description: 'Save $20 on orders over $100'
)

puts "Creating customer addresses..."
Address.create!(
  user: customer1,
  first_name: 'John',
  last_name: 'Doe',
  street_address: '123 Main Street',
  city: 'New York',
  state: 'NY',
  postal_code: '10001',
  country: 'United States',
  phone: '555-0123',
  is_default: true,
  address_type: :shipping
)

Address.create!(
  user: customer2,
  first_name: 'Jane',
  last_name: 'Smith',
  street_address: '456 Oak Avenue',
  city: 'Los Angeles',
  state: 'CA',
  postal_code: '90001',
  country: 'United States',
  phone: '555-0456',
  is_default: true,
  address_type: :shipping
)

puts "Creating sample reviews..."
Review.create!(
  user: customer1,
  product: product1,
  rating: 5,
  title: 'Amazing phone!',
  comment: 'The iPhone 15 Pro is incredible. The camera quality is outstanding and the titanium design feels premium.',
  status: :approved,
  verified_purchase: true
)

Review.create!(
  user: customer2,
  product: product1,
  rating: 4,
  title: 'Great but expensive',
  comment: 'Love the features but the price is quite high. Still worth it for the quality.',
  status: :approved,
  verified_purchase: true
)

Review.create!(
  user: customer1,
  product: product4,
  rating: 5,
  title: 'Most comfortable shoes',
  comment: 'These Nike Air Max are the most comfortable shoes I have ever owned. Perfect for running and everyday wear.',
  status: :approved,
  verified_purchase: true
)

Review.create!(
  user: customer2,
  product: product6,
  rating: 4,
  title: 'Good value for money',
  comment: 'Very comfortable chair for the price. Assembly was easy and it looks great in my living room.',
  status: :pending,
  verified_purchase: false
)

puts "Creating sample orders..."
order1 = Order.create!(
  user: customer1,
  order_number: "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}",
  status: :delivered,
  payment_status: :paid,
  payment_method: 'stripe',
  subtotal: 1149.98,
  tax_amount: 114.99,
  shipping_cost: 9.99,
  discount_amount: 0,
  total_price: 1274.96
)

OrderItem.create!(
  order: order1,
  product: product1,
  quantity: 1,
  unit_price: product1.price,
  total_price: product1.price,
  product_name: product1.name,
  product_sku: product1.sku
)

OrderItem.create!(
  order: order1,
  product: product4,
  quantity: 1,
  unit_price: product4.price,
  total_price: product4.price,
  product_name: product4.name,
  product_sku: product4.sku
)

puts "Seed data created successfully!"
puts ""
puts "=" * 50
puts "LOGIN CREDENTIALS:"
puts "=" * 50
puts "Admin:"
puts "  Email: admin@luxecart.com"
puts "  Password: password123"
puts ""
puts "Customer:"
puts "  Email: customer@example.com"
puts "  Password: password123"
puts "=" * 50

