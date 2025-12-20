# Clear existing data
puts "Cleaning database..."
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
Coupon.destroy_all

puts "Creating admin user..."
admin = User.create!(
  email: 'admin@luxecart.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: 'admin'
)

puts "Creating regular users..."
user1 = User.create!(
  email: 'john@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'John',
  last_name: 'Doe'
)

user2 = User.create!(
  email: 'jane@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Jane',
  last_name: 'Smith'
)

puts "Creating brands..."
brands = []
['Apple', 'Samsung', 'Sony', 'Nike', 'Adidas', 'Canon', 'Dell', 'HP'].each do |name|
  brands << Brand.create!(
    name: name,
    description: "Premium #{name} products",
    active: true,
    featured: [true, false].sample
  )
end

puts "Creating categories..."
electronics = Category.create!(name: 'Electronics', description: 'Electronic devices and accessories', active: true)
phones = Category.create!(name: 'Smartphones', description: 'Mobile phones', active: true, parent_category_id: electronics.id)
laptops = Category.create!(name: 'Laptops', description: 'Portable computers', active: true, parent_category_id: electronics.id)

clothing = Category.create!(name: 'Clothing', description: 'Fashion and apparel', active: true)
mens = Category.create!(name: "Men's Wear", description: 'Clothing for men', active: true, parent_category_id: clothing.id)
womens = Category.create!(name: "Women's Wear", description: 'Clothing for women', active: true, parent_category_id: clothing.id)

sports = Category.create!(name: 'Sports & Outdoors', description: 'Sports equipment and gear', active: true)

puts "Creating products..."
products = []

products << Product.create!(
  name: 'iPhone 15 Pro',
  description: 'Latest iPhone with A17 Pro chip, titanium design, and advanced camera system',
  price: 999.99,
  sale_price: 949.99,
  sku: 'IPH15PRO',
  stock_quantity: 50,
  category: phones,
  brand: brands.find { |b| b.name == 'Apple' },
  active: true,
  featured: true
)

products << Product.create!(
  name: 'Samsung Galaxy S24',
  description: 'Flagship Samsung phone with AI features and stunning display',
  price: 899.99,
  sku: 'SAMS24',
  stock_quantity: 45,
  category: phones,
  brand: brands.find { |b| b.name == 'Samsung' },
  active: true,
  featured: true
)

products << Product.create!(
  name: 'MacBook Pro 16"',
  description: 'Powerful laptop with M3 Pro chip for professionals',
  price: 2499.99,
  sku: 'MBP16M3',
  stock_quantity: 20,
  category: laptops,
  brand: brands.find { |b| b.name == 'Apple' },
  active: true,
  featured: true
)

products << Product.create!(
  name: 'Dell XPS 15',
  description: 'Premium Windows laptop with stunning InfinityEdge display',
  price: 1799.99,
  sale_price: 1699.99,
  sku: 'DELLXPS15',
  stock_quantity: 15,
  category: laptops,
  brand: brands.find { |b| b.name == 'Dell' },
  active: true,
  featured: false
)

products << Product.create!(
  name: 'Nike Air Max 2024',
  description: 'Iconic Nike sneakers with maximum comfort and style',
  price: 159.99,
  sku: 'NIKEAM24',
  stock_quantity: 100,
  category: mens,
  brand: brands.find { |b| b.name == 'Nike' },
  active: true,
  featured: true
)

products << Product.create!(
  name: 'Adidas Ultraboost',
  description: 'Premium running shoes with Boost technology',
  price: 189.99,
  sale_price: 149.99,
  sku: 'ADIUB',
  stock_quantity: 80,
  category: sports,
  brand: brands.find { |b| b.name == 'Adidas' },
  active: true,
  featured: true
)

puts "Creating coupons..."
Coupon.create!(
  code: 'WELCOME10',
  discount_type: :percentage,
  discount_value: 10,
  active: true,
  valid_from: Date.today,
  valid_until: Date.today + 30.days
)

Coupon.create!(
  code: 'SAVE50',
  discount_type: :fixed_amount,
  discount_value: 50,
  active: true,
  valid_from: Date.today,
  valid_until: Date.today + 7.days
)

puts "Creating addresses..."
Address.create!(
  user: user1,
  first_name: 'John',
  last_name: 'Doe',
  street_address: '123 Main St',
  city: 'New York',
  state: 'NY',
  postal_code: '10001',
  country: 'USA',
  phone: '555-1234',
  address_type: :both,
  is_default: true
)

puts "Creating reviews..."
products.each do |product|
  rand(2..5).times do
    Review.create!(
      user: [user1, user2].sample,
      product: product,
      rating: rand(3..5),
      title: 'Great product!',
      comment: 'Really satisfied with this purchase. Highly recommended!',
      status: :approved
    )
  end
end

puts "Creating orders..."
order = Order.create!(
  user: user1,
  status: :delivered,
  payment_status: :paid,
  payment_method: 'stripe',
  notes: 'Please deliver before 5 PM'
)

OrderItem.create!(
  order: order,
  product: products.first,
  quantity: 1,
  unit_price: products.first.price
)

puts "Seeds completed successfully!"
puts "Admin credentials: admin@luxecart.com / password123"
puts "User credentials: john@example.com / password123"
