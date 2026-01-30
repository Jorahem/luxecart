# db/seeds.rb
# Comprehensive seeds for LuxeCart (development)
#
# - Ensures categories, brands, clothing subcategories exist
# - Seeds a curated list of products (with images)
# - Seeds explicit collections (Men/Women/Children/Shoes/etc.)
# - Adds demo products until a desired total is reached
#
# Usage:
#   bin/rails db:seed
# or:
#   bundle exec rails db:seed
#
# Notes:
# - This script attempts multiple strategies to set product images:
#   - string column `image` or `image_url`
#   - ActiveStorage single attachment `image`
#   - ActiveStorage collection `images`
# - It is idempotent and safe to run multiple times.
# - If your Product model requires extra attributes, the script will try to set sensible defaults where possible.

require 'open-uri'
require 'securerandom'

puts "Starting seeds..."

# ---------------------------
# 1) Basic categories & brands
# ---------------------------

User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "securepassword"
  u.password_confirmation = "securepassword"
  u.admin = true if u.respond_to?(:admin=)
  u.first_name = "Admin" if u.respond_to?(:first_name=) && u.first_name.blank?
  u.last_name  = "User"  if u.respond_to?(:last_name=)  && u.last_name.blank?
end

base_categories = [
  'Furniture', 'Lighting', 'Decor', 'Textiles', 'Tables',
  'Accessories', 'Shoes', 'Underwear', 'New Arrivals', 'Sale', 'Smartwatch'
]

base_categories.each do |name|
  Category.find_or_create_by!(name: name)
end

brands = ['LuxeHome', 'NordicDesign', 'StudioCraft', 'ModernHouse']
brands.each { |b| Brand.find_or_create_by!(name: b) }

# Create Clothing parent and subcategories (Men / Women / Children)
clothing = Category.find_or_create_by!(name: "Clothing") do |c|
  c.slug = "clothing" if c.respond_to?(:slug=)
  c.active = true if c.respond_to?(:active=)
end

%w[Men Women Children].each do |child_name|
  Category.find_or_create_by!(name: child_name) do |c|
    c.parent_id = clothing.id if c.respond_to?(:parent_id=)
    c.slug = child_name.parameterize if c.respond_to?(:slug=)
    c.active = true if c.respond_to?(:active=)
  end
end

puts "Categories and brands ensured."

# ---------------------------
# 2) Curated initial product data
# ---------------------------
# UPDATED to use the nicer image URLs you had in scripts/update_products.rb
products_data = [
  {
    name: 'Luxe Velvet Chair',
    description: 'Plush velvet lounge chair with solid wood legs.',
    price: 249.99,
    image: 'https://i5.walmartimages.com/seo/Baxton-Studio-Cosette-Glam-and-Luxe-Light-Pink-Velvet-Fabric-Upholstered-Brushed-Gold-Finished-Seashell-Shaped-Accent-Chair_738dabea-3730-47ea-909e-302eb8b0dc58.71eec7ddca6b8f7c68a83e84608d2738.jpeg',
    category: 'Furniture',
    brand: 'LuxeHome'
  },
  {
    name: 'Modern Floor Lamp',
    description: 'Sleek metal floor lamp with dimmable LED.',
    price: 89.50,
    image: 'https://di2ponv0v5otw.cloudfront.net/posts/2025/01/25/67951bf74f80f955002fecf9/m_67951c7547c130b2b0749efb.jpeg',
    category: 'Lighting',
    brand: 'NordicDesign'
  },
  {
    name: 'Handwoven Rug',
    description: 'Handwoven area rug with geometric patterns.',
    price: 199.95,
    image: 'https://cdn.shopify.com/s/files/1/1159/3118/files/holiday24_ashlar-handwoven-rug-tawny_detail_silo-_1x1_jw.jpg?v=1736296960',
    category: 'Decor',
    brand: 'StudioCraft'
  },
  {
    name: 'Oak Coffee Table',
    description: 'Solid oak coffee table with minimalist finish.',
    price: 159.00,
    image: 'https://funky-chunky-furniture.co.uk/cdn/shop/products/salters-oak-coffee-table-33777-1-p.jpg?v=1643646322',
    category: 'Tables',
    brand: 'ModernHouse'
  },
  {
    name: 'Ceramic Vase Set',
    description: 'Artisan ceramic vases in three sizes.',
    price: 49.99,
    image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9bINwLC6UkuTxtCmyTdWJ0v3OWdRSReZO6Q&s',
    category: 'Decor',
    brand: 'StudioCraft'
  },
  {
    name: 'Luxe Bed Linen',
    description: 'Egyptian cotton bed linen for luxurious sleep.',
    price: 129.00,
    image: 'https://sowlhome.com/cdn/shop/files/sowl_athens_bed_set_organic_100_cotton_percale_linen_beige_white_duvet_cover_240_220_pillow_cases_50_75_product.jpg?v=1715346346&width=1700',
    category: 'Textiles',
    brand: 'LuxeHome'
  },
  {
    name: 'Minimalist Bookshelf',
    description: 'Floating bookshelf with clean lines.',
    price: 179.99,
    image: 'https://theminimalistvegan.com/wp-content/uploads/2024/01/Best-Minimalist-Bookshelf-Design-Ideas.jpg',
    category: 'Furniture',
    brand: 'NordicDesign'
  },
  {
    name: 'Designer Throw Pillow',
    description: 'Soft throw pillow with handcrafted cover.',
    price: 29.99,
    image: 'https://shoppersfortune.com/cdn/shop/files/ShoppersFortuneCottonFeelDesignerThrowPillowDecorativeCushionCovers-CuteOwls_FloraSetof5A.jpg?v=1689257687',
    category: 'Textiles',
    brand: 'StudioCraft'
  },
  {
    name: 'Contemporary Wall Art',
    description: 'Framed print with abstract composition.',
    price: 89.00,
    image: 'https://ak1.ostkcdn.com/images/products/is/images/direct/ecb2a34deb10a54f12119f2adbf487d9d5444041/Designart-%22White-And-Blue-Feather-Spiral-II%22-Abstract-Geometric-Blue-Wall-Decor---Modern-Entryway-Framed-Wall-Art.jpg',
    category: 'Decor',
    brand: 'ModernHouse'
  },
  {
    name: 'Nordic Dining Chair',
    description: 'Comfortable dining chair with tapered legs.',
    price: 99.00,
    image: 'https://image.made-in-china.com/365f3j00gpQoAnWECjcV/Nordic-Wooden-Dining-Chair-Cushion-Genuine-Fabric-Dinning-Chair.webp',
    category: 'Furniture',
    brand: 'NordicDesign'
  }
]

# ---------------------------
# 3) Sample images map for demo creation
# ---------------------------
sample_images_by_category = {
  'Furniture' => [
    'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1501045661006-fcebe0257c3f?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1493666438817-866a91353ca9?q=80&w=1200&auto=format&fit=crop'
  ],
  'Lighting' => [
    'https://images.unsplash.com/photo-1505691723518-36a5ac3be353?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1497032628192-86f99bcd76bc?q=80&w=1200&auto=format&fit=crop'
  ],
  'Decor' => [
    'https://images.unsplash.com/photo-1493666438817-866a91353ca9?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop'
  ],
  'Textiles' => [
    'https://images.unsplash.com/photo-1520975681500-99f9e6a7b3b8?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?q=80&w=1200&auto=format&fit=crop'
  ],
  'Tables' => [
    'https://images.unsplash.com/photo-1505692794400-7c6050b7c7d6?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1481277542470-605612bd2d61?q=80&w=1200&auto=format&fit=crop'
  ],
  'default' => [
    'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1520975918479-9a4b4f9b6c3a?q=80&w=1200&auto=format&fit=crop'
  ]
}

# ---------------------------
# 4) Helper to set product image (tries multiple strategies)
# ---------------------------
def set_product_image(product, image_url)
  return false if image_url.blank?

  # A: string column 'image'
  if Product.column_names.include?('image') && product.respond_to?(:image=)
    begin
      product.update_column(:image, image_url)
      return true
    rescue => e
      puts "[seeds] update_column(:image) failed for #{product.name}: #{e.class} - #{e.message}"
    end
  end

  # B: string column 'image_url'
  if Product.column_names.include?('image_url') && product.respond_to?(:image_url=)
    begin
      product.update_column(:image_url, image_url)
      return true
    rescue => e
      puts "[seeds] update_column(:image_url) failed for #{product.name}: #{e.class} - #{e.message}"
    end
  end

  # C: ActiveStorage single attachment `image`
  if product.respond_to?(:image) && product.image.respond_to?(:attach)
    begin
      io = URI.open(image_url)
      product.image.attach(io: io, filename: "#{product.name.parameterize}.jpg", content_type: io.content_type)
      return true
    rescue => e
      puts "[seeds] ActiveStorage attach failed for #{product.name}: #{e.class} - #{e.message}"
    end
  end

  # D: ActiveStorage collection `images`
  if product.respond_to?(:images) && product.images.respond_to?(:attach)
    begin
      io = URI.open(image_url)
      product.images.attach(io: io, filename: "#{product.name.parameterize}.jpg", content_type: io.content_type)
      return true
    rescue => e
      puts "[seeds] ActiveStorage (images) attach failed for #{product.name}: #{e.class} - #{e.message}"
    end
  end

  puts "[seeds] No image setter matched for Product #{product.name}; skipping image."
  false
end

# ---------------------------
# 5) Create/update curated initial products
# ---------------------------
puts "Seeding curated products..."

created = 0
updated = 0

products_data.each do |attrs|
  begin
    category = Category.find_by(name: attrs[:category])
    brand    = Brand.find_by(name: attrs[:brand])

    unless category && brand
      puts "Skipping #{attrs[:name]}: missing category or brand (#{attrs[:category]}, #{attrs[:brand]})"
      next
    end

    product   = Product.find_or_initialize_by(name: attrs[:name])
    new_record = product.new_record?

    product.description = attrs[:description] if product.respond_to?(:description=)
    product.price       = attrs[:price]       if product.respond_to?(:price=)
    product.category    = category            if product.respond_to?(:category=)
    product.brand       = brand               if product.respond_to?(:brand=)

    # generate SKU if model supports it
    if product.respond_to?(:sku=) && product.sku.blank?
      product.sku = "#{product.name.parameterize.upcase}-#{SecureRandom.hex(3)}"
    end

    # sensible defaults
    product.track_inventory = true  if product.respond_to?(:track_inventory=) && product.track_inventory.nil?
    product.stock_quantity  = 100   if product.respond_to?(:stock_quantity=) && (product.stock_quantity.nil? || product.stock_quantity.zero?)
    product.status          = 'active' if product.respond_to?(:status=) && product.status.blank?
    product.active          = true  if product.respond_to?(:active=) && product.active.nil?

    product.save!
    new_record ? created += 1 : updated += 1

    image_url = attrs[:image].presence || attrs[:image_url].presence
    set_product_image(product, image_url) if image_url.present?

    puts "Saved product: #{product.name} (id: #{product.id})"
  rescue ActiveRecord::RecordInvalid => e
    puts "[seeds] Validation failed for #{attrs[:name]}: #{e.record.errors.full_messages.join(', ')}"
  rescue => e
    puts "[seeds] Failed to create/update #{attrs[:name]}: #{e.class} - #{e.message}"
  end
end

puts "Curated products processed. Created: #{created}, Updated: #{updated}"

# ---------------------------
# 6) Explicit collections (Men/Women/Children/Shoes/...)
# ---------------------------
collections = {
  "Men" => [
    { name: "Classic Denim Jacket", price: 79.99, image_url: "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=800&q=80", description: "A timeless denim jacket with a slim cut — perfect for layered looks." },
    { name: "Casual Chambray Shirt", price: 39.50, image_url: "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?auto=format&fit=crop&w=800&q=80", description: "Soft chambray shirt, breathable and comfortable for everyday wear." },
    { name: "Slim Fit Chinos", price: 49.00, image_url: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=800&q=80", description: "Versatile slim chinos with just the right stretch for movement." },
    { name: "Classic White T-Shirt", price: 12.99, image_url: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80", description: "Soft cotton classic white t-shirt for everyday wear." },
    { name: "Casual Denim Jacket", price: 49.99, image_url: "https://images.unsplash.com/photo-1516826957135-700dedea698c?auto=format&fit=crop&w=800&q=80", description: "Stylish denim jacket perfect for casual outings." },
    { name: "Slim Fit Blue Jeans", price: 39.99, image_url: "https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=800&q=80", description: "Comfortable slim-fit jeans with a modern look." },
    { name: "Formal Black Shirt", price: 24.99, image_url: "https://images.unsplash.com/photo-1593032465175-481ac7f401a0?auto=format&fit=crop&w=800&q=80", description: "Elegant black shirt suitable for office and events." },
    { name: "Men's Hoodie", price: 29.99, image_url: "https://images.unsplash.com/photo-1618354691438-25bc04584c23?auto=format&fit=crop&w=800&q=80", description: "Warm and cozy hoodie for daily comfort." },
    { name: "Chino Pants", price: 34.99, image_url: "https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=800&q=80", description: "Versatile chino pants for casual and semi-formal wear." },
    { name: "Checked Casual Shirt", price: 22.99, image_url: "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=800&q=80", description: "Trendy checked shirt made with breathable fabric." },
    { name: "Men's Bomber Jacket", price: 54.99, image_url: "https://images.unsplash.com/photo-1520975916090-3105956dac38?auto=format&fit=crop&w=800&q=80", description: "Lightweight bomber jacket with a sporty style." },
    { name: "Cotton Polo Shirt", price: 19.99, image_url: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?auto=format&fit=crop&w=800&q=80", description: "Classic polo shirt for a clean and smart look." },
    { name: "Men's Sweatpants", price: 27.99, image_url: "https://m.media-amazon.com/images/I/71wGEp-IHxL._AC_SL1000__.jpg", description: "Relaxed-fit sweatpants ideal for lounging or workouts." },
    { name: "Formal Grey Trousers", price: 36.99, image_url: "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80", description: "Professional grey trousers for office wear." },
    { name: "Winter Puffer Jacket", price: 79.99, image_url: "https://images.unsplash.com/photo-1608228088998-57828365d486?auto=format&fit=crop&w=800&q=80", description: "Insulated puffer jacket to keep you warm in winter." },
    { name: "Round Neck Sweater", price: 31.99, image_url: "https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?auto=format&fit=crop&w=800&q=80", description: "Comfortable knit sweater for cool weather." },
    { name: "Men's Blazer", price: 89.99, image_url: "https://twillory.com/cdn/shop/files/PerformanceBlazer-HeatherLightGrey-Front.png?v=1761849346&width=1946", description: "Sharp blazer for formal and business occasions." },
    { name: "Casual Shorts", price: 18.99, image_url: "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=800&q=80", description: "Lightweight casual shorts for summer days." },
    { name: "Men's Linen Summer Shirt", price: 28.99, image_url: "https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?auto=format&fit=crop&w=800&q=80", description: "Breathable linen shirt ideal for hot weather." },
    { name: "Men's Cargo Pants", price: 44.99, image_url: "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=800&q=80", description: "Durable cargo pants with multiple utility pockets." },
    { name: "Men's Sleeveless Gym Tee", price: 19.99, image_url: "https://images.unsplash.com/photo-1605296867304-46d5465a13f1?auto=format&fit=crop&w=800&q=80", description: "Lightweight sleeveless tee for workouts." }
  ],

  "Women" => [
    { name: "Lace Trim Briefs", price: 12.99, image_url: "https://www.curvy.com.au/cdn/shop/products/bendon-everyday-lace-trim-brazilian-brief-black1.jpg?v=1638501936", description: "Soft briefs with delicate lace trim for everyday comfort." },
    { name: "Silk Slip Dress", price: 129.00, image_url: "https://lizzys.ca/cdn/shop/files/DrapeNeckSatinSlipDress_BD103_Sage_LaDiv.jpg?v=1720199928", description: "Elegant slip dress in lightweight silk for evenings out." },
    { name: "Classic Cotton T-Shirt", price: 14.99, image_url: "https://www.american-giant.com/cdn/shop/files/W2-2T-3-WH_30449.jpg?v=1746651599", description: "Soft cotton t-shirt for everyday comfort and style." },
    { name: "Floral Summer Dress", price: 39.99, image_url: "https://www.graceandlace.com/cdn/shop/files/FloralSummerMaxiDress-1.jpg?v=1715707860", description: "Lightweight floral dress perfect for summer outings." },
    { name: "Women’s Denim Jacket", price: 49.99, image_url: "https://images.unsplash.com/photo-1521334884684-d80222895322?auto=format&fit=crop&w=800&q=80", description: "Stylish denim jacket for casual layering." },
    { name: "High-Waist Skinny Jeans", price: 42.99, image_url: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=800&q=80", description: "Figure-flattering skinny jeans with a high-waist fit." },
    { name: "Elegant Blouse", price: 24.99, image_url: "https://images.unsplash.com/photo-1593032465175-481ac7f401a0?auto=format&fit=crop&w=800&q=80", description: "Chic blouse suitable for office and casual wear." },
    { name: "Women’s Hoodie", price: 32.99, image_url: "https://images.unsplash.com/photo-1618354691438-25bc04584c23?auto=format&fit=crop&w=800&q=80", description: "Cozy hoodie designed for everyday warmth." },
    { name: "Pleated Midi Skirt", price: 34.99, image_url: "https://images.unsplash.com/photo-1591369822096-ffd140ec948f?auto=format&fit=crop&w=800&q=80", description: "Elegant pleated skirt for a modern feminine look." },
    { name: "Women’s Knit Sweater", price: 36.99, image_url: "https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?auto=format&fit=crop&w=800&q=80", description: "Warm knitted sweater for cool days." },
    { name: "Casual Button-Up Shirt", price: 26.99, image_url: "https://images.unsplash.com/photo-1520975916090-3105956dac38?auto=format&fit=crop&w=800&q=80", description: "Relaxed-fit button-up shirt for everyday wear." },
    { name: "Women’s Blazer", price: 89.99, image_url: "https://pangaia.com/cdn/shop/files/Womens-Cotton-Tailored-Jacket-Black-1.png?crop=center&height=1999&v=1755271639&width=1500", description: "Tailored blazer for formal and professional looks." },
    { name: "High-Waist Trousers", price: 38.99, image_url: "https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=800&q=80", description: "Comfortable high-waist trousers for work and casual wear." },
    { name: "Winter Puffer Jacket", price: 79.99, image_url: "https://images.unsplash.com/photo-1608228088998-57828365d486?auto=format&fit=crop&w=800&q=80", description: "Insulated jacket designed to keep you warm in winter." },
    { name: "Casual Summer Shorts", price: 19.99, image_url: "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=800&q=80", description: "Lightweight shorts perfect for summer days." },
    { name: "Women’s Cardigan", price: 29.99, image_url: "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=800&q=80", description: "Soft cardigan ideal for layering in cooler weather." },
    { name: "Evening Party Dress", price: 69.99, image_url: "https://images.unsplash.com/photo-1519744792095-2f2205e87b6f?auto=format&fit=crop&w=800&q=80", description: "Elegant party dress designed for special occasions." },
    { name: "Women’s Wrap Skirt", price: 33.99, image_url: "https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?auto=format&fit=crop&w=800&q=80", description: "Elegant wrap skirt with adjustable fit." },
    { name: "Women’s Puff Sleeve Top", price: 26.99, image_url: "https://images.unsplash.com/photo-1556905055-8f358a7a47b2?auto=format&fit=crop&w=800&q=80", description: "Stylish puff sleeve top for casual wear." },
    { name: "Women’s Palazzo Pants", price: 41.99, image_url: "https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=800&q=80", description: "Flowy palazzo pants for comfort and elegance." }
  ],

  "Children" => [
    { name: "Playtime T-Shirt", price: 14.99, image_url: "https://images.unsplash.com/photo-1600180758895-3bdaa9f3a8d8?auto=format&fit=crop&w=800&q=80", description: "Durable cotton tee for playtime and school." },
    { name: "Comfy Shorts", price: 16.50, image_url: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&q=80", description: "Elastic waist shorts for comfort and movement." },
    { name: "Playtime T-Shirt (Alt)", price: 14.99, image_url: "https://poppyplaytime.com/cdn/shop/files/W5O053A_1.jpg?v=1722976528&width=1600", description: "Durable cotton t-shirt for playtime and school." },
    { name: "Kids Denim Jacket", price: 34.99, image_url: "https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=800&q=80", description: "Stylish denim jacket for kids’ casual outfits." },
    { name: "Cartoon Print Hoodie", price: 29.99, image_url: "https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=800&q=80", description: "Warm hoodie with fun cartoon prints for kids." },
    { name: "Kids Jogger Pants", price: 22.99, image_url: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=800&q=80", description: "Comfortable jogger pants for daily activities." },
    { name: "Girls Floral Dress", price: 39.99, image_url: "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?auto=format&fit=crop&w=800&q=80", description: "Cute floral dress perfect for parties and outings." },
    { name: "Boys Casual Shirt", price: 24.99, image_url: "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=800&q=80", description: "Soft cotton shirt for boys’ casual wear." },
    { name: "Kids Winter Jacket", price: 49.99, image_url: "https://images.unsplash.com/photo-1608228088998-57828365d486?auto=format&fit=crop&w=800&q=80", description: "Warm winter jacket to keep kids cozy." },
    { name: "Kids Cotton Shorts", price: 18.99, image_url: "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=800&q=80", description: "Lightweight cotton shorts for summer days." },
    { name: "School Uniform Shirt", price: 19.99, image_url: "https://5.imimg.com/data5/SELLER/Default/2023/5/308202427/KN/AM/CE/3316870/school-uniform-shirt.jpg", description: "Neat and comfortable school uniform shirt." },
    { name: "Kids Sweatshirt", price: 27.99, image_url: "https://images.unsplash.com/photo-1618354691438-25bc04584c23?auto=format&fit=crop&w=800&q=80", description: "Soft sweatshirt for everyday warmth." },
    { name: "Baby Romper Suit", price: 21.99, image_url: "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=800&q=80", description: "Comfortable romper suit for babies." },
    { name: "Kids Pajama Set", price: 25.99, image_url: "https://images.unsplash.com/photo-1607082349566-187342175e2f?auto=format&fit=crop&w=800&q=80", description: "Soft pajama set for a good night’s sleep." },
    { name: "Kids Raincoat", price: 31.99, image_url: "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=800&q=80", description: "Waterproof raincoat for rainy days." },
    { name: "Festive Kids Kurta", price: 44.99, image_url: "https://images.unsplash.com/photo-1618220179428-22790b461013?auto=format&fit=crop&w=800&q=80", description: "Traditional kurta for festivals and celebrations." },
    { name: "Kids Wool Sweater", price: 28.99, image_url: "https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?auto=format&fit=crop&w=800&q=80", description: "Warm wool sweater for cold weather." },
    { name: "Kids Dinosaur T-Shirt", price: 16.99, image_url: "https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=800&q=80", description: "Fun dinosaur print t-shirt kids will love." },
    { name: "Girls Tulle Party Dress", price: 45.99, image_url: "https://www.carlyna.com/cdn/shop/files/floral-applique-puffy-tulle-flower-girl-dress-fg000001-a_720x.jpg?v=1699434280", description: "Beautiful tulle dress for parties and events." },
    { name: "Boys Denim Overalls", price: 38.99, image_url: "https://images.unsplash.com/photo-1543852786-1cf6624b9987?auto=format&fit=crop&w=800&q=80", description: "Classic denim overalls for playful days." }
  ],

  "Shoes" => [
    # MEN'S SHOES
    { name: "Men's Classic Sneakers", price: 59.99, image_url: "https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=900&q=80", description: "Everyday men's sneakers with a clean minimal profile." },
    { name: "Men's Running Shoes", price: 69.99, image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80", description: "Lightweight running shoes built for daily training." },
    { name: "Men's Leather Loafers", price: 84.99, image_url: "https://images.unsplash.com/photo-1528701800489-20be3c30c1d5?auto=format&fit=crop&w=900&q=80", description: "Slip‑on leather loafers for smart casual looks." },

    # WOMEN'S SHOES
    { name: "Women's White Sneakers", price: 64.99, image_url: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80", description: "Crisp white sneakers styled for everyday outfits." },
    { name: "Women's Block Heels", price: 72.99, image_url: "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=900&q=80", description: "Comfortable block heels for parties and events." },
    { name: "Women's Strap Sandals", price: 39.99, image_url: "https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=900&q=80", description: "Strappy sandals perfect for warm summer days." },

    # CHILDREN'S SHOES
    { name: "Kids Sport Sneakers", price: 39.99, image_url: "https://images.unsplash.com/photo-1508189860359-777d945909ef?auto=format&fit=crop&w=900&q=80", description: "Durable sport sneakers for active kids." },
    { name: "Kids Everyday Trainers", price: 34.99, image_url: "https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=900&q=80", description: "Light trainers for school and playground." },
    { name: "Kids Velcro Shoes", price: 29.99, image_url: "https://images.unsplash.com/photo-1514986888952-8cd320577b68?auto=format&fit=crop&w=900&q=80", description: "Easy‑on velcro shoes designed for little feet." }
  ],

 "Decor" => [
  {
    name: "Handwoven Rug",
    price: 199.95,
    image_url: "https://cdn.shopify.com/s/files/1/1159/3118/files/holiday24_ashlar-handwoven-rug-tawny_detail_silo-_1x1_jw.jpg?v=1736296960",
    description: "Handwoven area rug with geometric patterns."
  },
  {
    name: "Ceramic Vase Set",
    price: 49.99,
    image_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9bINwLC6UkuTxtCmyTdWJ0v3OWdRSReZO6Q&s",
    description: "Artisan ceramic vases in three sizes."
  },
  {
    name: "Contemporary Wall Art",
    price: 89.00,
    image_url: "https://ak1.ostkcdn.com/images/products/is/images/direct/ecb2a34deb10a54f12119f2adbf487d9d5444041/Designart-%22White-And-Blue-Feather-Spiral-II%22-Abstract-Geometric-Blue-Wall-Decor---Modern-Entryway-Framed-Wall-Art.jpg",
    description: "Framed print with abstract composition."
  },
  # existing decor items...
],

  "Furniture" => [
  {
    name: "Luxe Velvet Chair",
    price: 249.99,
    image_url: "https://i5.walmartimages.com/seo/Baxton-Studio-Cosette-Glam-and-Luxe-Light-Pink-Velvet-Fabric-Upholstered-Brushed-Gold-Finished-Seashell-Shaped-Accent-Chair_738dabea-3730-47ea-909e-302eb8b0dc58.71eec7ddca6b8f7c68a83e84608d2738.jpeg",
    description: "Plush velvet lounge chair with solid wood legs."
  },
  {
    name: "Nordic Dining Chair",
    price: 129.00,
    image_url: "https://image.made-in-china.com/365f3j00gpQoAnWECjcV/Nordic-Wooden-Dining-Chair-Cushion-Genuine-Fabric-Dinning-Chair.webp",
    description: "Clean-lined dining chair with comfortable seat."
  },
  {
    name: "Accent Armchair",
    price: 249.99,
    image_url: "https://images.unsplash.com/photo-1493666438817-866a91353ca9?auto=format&fit=crop&w=800&q=80",
    description: "Cozy accent chair for reading corners."
  }
],

  "Lighting" => [
    { name: "Pendant Lamp", price: 129.00, image_url: "https://images.unsplash.com/photo-1505691723518-11a9f8a6a1df?auto=format&fit=crop&w=800&q=80", description: "Brass pendant to lift your dining area." },
    { name: "Table Lamp", price: 69.00, image_url: "https://images.unsplash.com/photo-1524758631624-7b5d2d1b9e0a?auto=format&fit=crop&w=800&q=80", description: "Soft-diffuse table lamp for bedside." }
  ],

  "Accessories" => [
    { name:"Women’s Leather Handbag",price:49.99,image_url:"https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=800&q=80",description:"Stylish leather handbag perfect for everyday use."},
    { name:"Women’s Sunglasses",price:19.99,image_url:"https://images.unsplash.com/photo-1519627154379-4ec1d6e5afa0?auto=format&fit=crop&w=800&q=80",description:"Classic sunglasses with UV protection."},
    { name:"Women’s Silk Scarf",price:24.99,image_url:"https://images.unsplash.com/photo-1542068829-1115f7259450?auto=format&fit=crop&w=800&q=80",description:"Elegant silk scarf that elevates any outfit."},
    { name:"Women’s Statement Necklace",price:29.99,image_url:"https://images.unsplash.com/photo-1562158070-7a83d1e48ecf?auto=format&fit=crop&w=800&q=80",description:"Bold necklace for special occasions."},
    { name:"Women’s Hoop Earrings",price:14.99,image_url:"https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?auto=format&fit=crop&w=800&q=80",description:"Trendy hoop earrings for daily wear."},
    { name:"Women’s Watch Bracelet",price:39.99,image_url:"https://images.unsplash.com/photo-1518546305920-9d19619f9b18?auto=format&fit=crop&w=800&q=80",description:"Elegant bracelet watch for fashion and function."},
    { name:"Women’s Charm Bracelet",price:21.99,image_url:"https://images.unsplash.com/photo-1549880338-65ddcdfd017b?auto=format&fit=crop&w=800&q=80",description:"Cute charm bracelet to personalize your style."},
    { name:"Women’s Hair Clips Set",price:9.99,image_url:"https://images.unsplash.com/photo-1600185365926-3f8b8f82cda8?auto=format&fit=crop&w=800&q=80",description:"Set of stylish hair clips for every look."},
    { name:"Women’s Belt Accessory",price:17.99,image_url:"https://images.unsplash.com/photo-1555529669-9a6b46ae4884?auto=format&fit=crop&w=800&q=80",description:"Fashion belt to complete your outfit."},
    { name:"Women’s Tote Bag",price:34.99,image_url:"https://images.unsplash.com/photo-1495121605193-b116b5b09a19?auto=format&fit=crop&w=800&q=80",description:"Spacious tote bag for work or travel."},
    { name:"Men’s Leather Wallet",price:29.99,image_url:"https://images.unsplash.com/photo-1539874754764-5a9655914e71?auto=format&fit=crop&w=800&q=80",description:"Durable leather wallet with multiple slots."},
    { name:"Men’s Aviator Sunglasses",price:22.99,image_url:"https://images.unsplash.com/photo-1504198453319-5ce911bafcde?auto=format&fit=crop&w=800&q=80",description:"Classic aviator style sunglasses."},
    { name:"Men’s Watch",price:49.99,image_url:"https://images.unsplash.com/photo-1518544886132-1f7f9b1b47c3?auto=format&fit=crop&w=800&q=80",description:"Sleek watch with leather strap."},
    { name:"Men’s Bracelet",price:19.99,image_url:"https://images.unsplash.com/photo-1495121605193-b116b5b09a19?auto=format&fit=crop&w=800&q=80",description:"Stylish men’s bracelet for casual outfits."},
    { name:"Men’s Cap",price:15.99,image_url:"https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?auto=format&fit=crop&w=800&q=80",description:"Comfortable cap for everyday wear."},
    { name:"Men’s Tie",price:18.99,image_url:"https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=800&q=80",description:"Classic tie for formal occasions."},
    { name:"Men’s Cufflinks",price:25.99,image_url:"https://images.unsplash.com/photo-1600180758895-3bdaa9f3a8d8?auto=format&fit=crop&w=800&q=80",description:"Elegant cufflinks to elevate formal attire."},
    { name:"Men’s Keychain",price:9.99,image_url:"https://images.unsplash.com/photo-1555529669-9a6b46ae4884?auto=format&fit=crop&w=800&q=80",description:"Leather keychain with metal accents."},
    { name:"Men’s Backpack",price:39.99,image_url:"https://images.unsplash.com/photo-1520974735194-6c3b46c3b98b?auto=format&fit=crop&w=800&q=80",description:"Durable backpack for work or travel."},
    { name:"Men’s Gloves",price:24.99,image_url:"https://images.unsplash.com/photo-1519744792095-2f2205e87b6f?auto=format&fit=crop&w=800&q=80",description:"Warm gloves for cold weather."}
  ],

  "New Arrivals" => [
    { name: "Summer Cotton Kurta", price: 23.99, image_url: "https://images.unsplash.com/photo-1523381213953-0d0a5f2a0d1c?auto=format&fit=crop&w=800&q=80", description: "Light, breezy kurta for sunny days." },
    { name: "Tailored Blazer", price: 89.99, image_url: "https://images.unsplash.com/photo-1592878849122-3f8b8f82cda8?auto=format&fit=crop&w=800&q=80", description: "Sharp blazer perfect for office meetings." },
    { name: "Floral Midi Dress", price: 42.99, image_url: "https://images.unsplash.com/photo-1520975682031-a9c3c8c23e36?auto=format&fit=crop&w=800&q=80", description: "Elegant floral dress for daytime occasions." },
    { name: "Kids Printed Hoodie", price: 27.99, image_url: "https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=800&q=80", description: "Cartoon print hoodie for fun and warmth." },
    { name: "Cotton Button-Up Shirt", price: 33.99, image_url: "https://images.unsplash.com/photo-1520975916090-3105956dac38?auto=format&fit=crop&w=800&q=80", description: "Modern cotton shirt, easy for work and leisure." }
  ],

  "Tables" => [
    { name: "Dining Table", price: 599.00, image_url: "https://images.unsplash.com/photo-1519710164239-481f0a6c0c3b?auto=format&fit=crop&w=800&q=80", description: "Solid wood dining table, seats 6." },
    { name: "Side Table", price: 89.00, image_url: "https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=800&q=80", description: "Compact side table for small spaces." }
  ],

  "Textiles" => [
    { name: "Woven Throw", price: 49.00, image_url: "https://i.pinimg.com/1200x/27/ce/0b/27ce0b6fb0ee2706a3513dace10f4c66.jpg", description: "Cozy throw blanket in woven cotton." },
    { name: "Decorative Rug", price: 249.00, image_url: "https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=800&q=80", description: "Hand-loomed rug for living spaces." },
    { name: "Linen Cushion Cover Set", price: 24.99, image_url: "https://i.pinimg.com/736x/9f/5f/e2/9f5fe267a69ec0e4a4d55a5ad4f7bc9a.jpg", description: "Soft linen cushion covers in neutral tones." },
    { name: "Stonewashed Linen Duvet Cover", price: 89.99, image_url: "https://i.pinimg.com/1200x/d8/44/23/d8442383371f0e3238961798a6c184fc.jpg", description: "Stonewashed linen duvet for a relaxed bedroom look." },
    { name: "Linen Throw Blanket", price: 39.99, image_url: "https://i.pinimg.com/736x/7d/15/d5/7d15d5014351bcc5a1bb802bcbea0175.jpg", description: "Lightweight linen throw to layer over sofas or beds." }
  ],

  "Sale" => [
    {
      name: "Basic Tee – 30% Off",
      price: 9.99,
      image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80",
      description: "Soft cotton t‑shirt with a 30% seasonal discount."
    },
    {
      name: "Denim Jacket – 50% Off",
      price: 59.99,
      image_url: "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=900&q=80",
      description: "Classic denim jacket now at 50% off."
    },
    {
      name: "Women’s White Sneakers – 40% Off",
      price: 49.99,
      image_url: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80",
      description: "Clean white sneakers with 40% off."
    },
    {
      name: "Kids Hoodie – 60% Off",
      price: 19.99,
      image_url: "https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=900&q=80",
      description: "Warm kids hoodie with a massive 60% discount."
    },
    {
      name: "Decorative Wall Art – 35% Off",
      price: 54.99,
      image_url: "https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=900&q=80",
      description: "Modern wall art print at 35% off."
    },
    {
      name: "Accent Armchair – 45% Off",
      price: 139.99,
      image_url: "https://images.unsplash.com/photo-1493666438817-866a91353ca9?auto=format&fit=crop&w=900&q=80",
      description: "Cozy armchair with 45% discount."
    }
  ],

  "Underwear" => [
    { name: "Seasonal Tee (Sale)", price: 9.99, image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80", description: "Basic tee at a special price." },
    { name: "Denim Jacket (Sale)", price: 59.99, image_url: "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=800&q=80", description: "Denim jacket with a markdown price." },
    { name: "Men's Cotton Briefs", price: 12.99, image_url: "https://images.unsplash.com/photo-1585386959984-a41552231692?auto=format&fit=crop&w=800&q=80", description: "Soft cotton briefs designed for everyday comfort." },
    { name: "Men's Boxer Shorts", price: 14.99, image_url: "https://images.unsplash.com/photo-1618354691438-25bc04584c23?auto=format&fit=crop&w=800&q=80", description: "Breathable boxer shorts for relaxed daily wear." },
    { name: "Men's Boxer Briefs", price: 16.99, image_url: "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=800&q=80", description: "Supportive boxer briefs with a snug fit." },
    { name: "Men's Sports Underwear", price: 18.99, image_url: "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&w=800&q=80", description: "Moisture-wicking underwear for active lifestyles." },
    { name: "Men's Thermal Underwear", price: 22.99, image_url: "https://images.unsplash.com/photo-1608228088998-57828365d486?auto=format&fit=crop&w=800&q=80", description: "Warm thermal underwear for cold weather." },
    { name: "Women's Cotton Panty", price: 11.99, image_url: "https://images.unsplash.com/photo-1520974735194-6c3b46c3b98b?auto=format&fit=crop&w=800&q=80", description: "Soft cotton panty designed for all-day comfort." },
    { name: "Women's Hipster Underwear", price: 13.99, image_url: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=800&q=80", description: "Comfortable hipster style with full coverage." },
    { name: "Women's Bikini Underwear", price: 12.99, image_url: "https://images.unsplash.com/photo-1591369822096-ffd140ec948f?auto=format&fit=crop&w=800&q=80", description: "Lightweight bikini underwear for daily wear." },
    { name: "Women's High-Waist Brief", price: 15.99, image_url: "https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=800&q=80", description: "High-waist brief offering extra comfort and support." },
    { name: "Women's Seamless Panty", price: 17.99, image_url: "https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?auto=format&fit=crop&w=800&q=80", description: "Seamless design for a smooth, invisible fit." },
    { name: "Women's Sports Underwear", price: 18.99, image_url: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?auto=format&fit=crop&w=800&q=80", description: "Breathable underwear designed for workouts." },
    { name: "Women's Thermal Underwear", price: 24.99, image_url: "https://images.unsplash.com/photo-1618220179428-22790b461013?auto=format&fit=crop&w=800&q=80", description: "Thermal underwear to keep warm in winter." },
    { name: "Men's Lounge Underwear Set", price: 27.99, image_url: "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=800&q=80", description: "Comfort-focused underwear set for relaxing at home." },
    { name: "Women's Everyday Comfort Pack", price: 29.99, image_url: "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=800&q=80", description: "Multi-pack underwear designed for daily use." },
    { name: "Unisex Cotton Underwear", price: 14.99, image_url: "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?auto=format&fit=crop&w=800&q=80", description: "Soft unisex underwear suitable for everyone." },
    { name: "Men's Bamboo Fiber Briefs", price: 17.99, image_url: "https://everythingbamboo.com.au/cdn/shop/products/Men-Soft-Bamboo-Fibre-Pure-Color-Shorts-Boxer-Briefs-Underwear-_-everythingbamboo-1658471984.jpg?v=1658471985&width=1445", description: "Eco-friendly bamboo briefs with breathable fabric." },
    { name: "Men's Anti-Chafe Boxer Briefs", price: 19.99, image_url: "https://images.unsplash.com/photo-1621609764095-b32bbe35cf3a?auto=format&fit=crop&w=800&q=80", description: "Designed to reduce friction and increase comfort." },
    { name: "Women's Lace-Free Comfort Panty", price: 15.99, image_url: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?auto=format&fit=crop&w=800&q=80", description: "Smooth, lace-free underwear for daily use." },
    { name: "Women's Maternity Underwear", price: 21.99, image_url: "https://www.ingridandisabel.com/cdn/shop/products/A0026UnderwearBundleBlack_Mauve_1080x.jpg?v=1665166604", description: "Extra-soft underwear designed for maternity comfort." },
    { name: "Kids Organic Cotton Undershirt", price: 13.99, image_url: "https://images.unsplash.com/photo-1607082349566-187342175e2f?auto=format&fit=crop&w=800&q=80", description: "Gentle organic cotton undershirt for kids." },
    { name: "Kids Training Underwear Pack", price: 24.99, image_url: "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=800&q=80", description: "Soft training underwear for growing children." }
  ],

  "Smartwatch" => [
    { name: "Smart Fitness Watch", price: 79.99, image_url: "https://img.drz.lazcdn.com/static/np/p/72f3041de192a935952b815f254e41cd.jpg_720x720q80.jpg", description: "Fitness smartwatch with heart rate and step tracking." },
    { name: "Classic Digital Smartwatch", price: 69.99, image_url: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80", description: "Sleek digital smartwatch with daily activity monitoring." },
    { name: "Sport Pro Smartwatch", price: 89.99, image_url: "https://images.unsplash.com/photo-1544117519-31a4b719223d?auto=format&fit=crop&w=800&q=80", description: "Rugged smartwatch designed for sports and workouts." },
    { name: "Luxury Metal Smartwatch", price: 129.99, image_url: "https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?auto=format&fit=crop&w=800&q=80", description: "Premium metal smartwatch with elegant design." },
    { name: "Minimal Touch Smartwatch", price: 59.99, image_url: "https://s.alicdn.com/@sc04/kf/Hbfece0be560946c3afb7e211f86635d5M/H9-Simple-Sports-Health-Tracker-Bluetooth-Smart-Watch-TFT-HD-Touch-Screen-Multi-function-Heart-Rate-Monitoring-Electronic-Watch.jpg", description: "Minimal smartwatch with touch display." },
    { name: "Health Monitor Smartwatch", price: 99.99, image_url: "https://images.unsplash.com/photo-1579586337278-3befd40fd17a?auto=format&fit=crop&w=800&q=80", description: "Advanced health monitoring smartwatch." },
    { name: "Kids Smartwatch", price: 49.99, image_url: "https://i0.wp.com/bestdealsnepal.com.np/wp-content/uploads/2019/08/gps-kids-watch.jpg?fit=500%2C500&ssl=1", description: "Smartwatch designed especially for kids." },
    { name: "Outdoor Adventure Smartwatch", price: 149.99, image_url: "https://res.garmin.com/subcategory/WW/GYM/GYM-CARD-INSTINCT-3.png", description: "GPS-enabled smartwatch for outdoor adventures." },
    { name: "Slim Band Smartwatch", price: 54.99, image_url: "https://images.mobilefun.co.uk/graphics/450pixelp/97908.jpg", description: "Slim and lightweight smartwatch band." },
    { name: "AMOLED Display Smartwatch", price: 119.99, image_url: "https://img.drz.lazcdn.com/static/np/p/2b0630bd654379394adca53cebd275a4.jpg_720x720q80.jpg", description: "Smartwatch with vibrant AMOLED display." }
  ]
}

puts "Seeding explicit collections..."

collections.each do |cat_name, items|
  cat = Category.find_or_create_by!(name: cat_name)

  items.each do |attrs|
    prod = Product.find_or_initialize_by(name: attrs[:name])

    prod.description = attrs[:description] if prod.respond_to?(:description=)
    prod.price       = attrs[:price]       if prod.respond_to?(:price=)
    prod.category    = cat                 if prod.respond_to?(:category=)

    # Choose or create a brand
    chosen_brand = nil
    chosen_brand = Brand.find_or_create_by!(name: attrs[:brand]) if attrs[:brand].present?
    chosen_brand ||= Brand.find_by(name: cat_name)
    chosen_brand ||= Brand.first
    prod.brand = chosen_brand if prod.respond_to?(:brand=) && chosen_brand

    prod.active = true if prod.respond_to?(:active=) && prod.active.nil?
    if prod.respond_to?(:sku=) && prod.sku.blank?
      prod.sku = "#{prod.name.parameterize.upcase}-#{SecureRandom.hex(3)}"
    end

    prod.save!
    image_url = attrs[:image_url].presence || attrs[:image].presence
    set_product_image(prod, image_url) if image_url.present?
  end
end

puts "Explicit collections seeded."

# ---------------------------
# 7) Create demo products until desired_total
# ---------------------------
desired_total  = 35
current_total  = Product.count
to_create      = [0, desired_total - current_total].max

if to_create > 0
  puts "Creating #{to_create} demo products to reach #{desired_total} total..."
  demo_created      = 0
  category_records  = Category.all.to_a
  brand_records     = Brand.all.to_a
  idx               = 0

  while demo_created < to_create
    cat   = category_records[idx % category_records.length]
    brand = brand_records[idx % brand_records.length]
    seq   = Product.where("name LIKE ?", "#{cat.name} Demo %").count + 1
    demo_name = "#{cat.name} Demo #{seq}"

    if Product.exists?(name: demo_name)
      idx += 1
      next
    end

    p = Product.new
    p.name        = demo_name
    p.description = "Demo #{demo_name} — sample product created by seeds for category #{cat.name}." if p.respond_to?(:description=)
    price         = (((20 + rand * 480) * 100).round) / 100.0

    if p.respond_to?(:price=)
      p.price = price
    elsif p.respond_to?(:unit_price_decimal=)
      p.unit_price_decimal = price
    end

    p.category        = cat   if p.respond_to?(:category=)
    p.brand           = brand if p.respond_to?(:brand=)
    p.track_inventory = true  if p.respond_to?(:track_inventory=) && p.track_inventory.nil?
    p.stock_quantity  = 50    if p.respond_to?(:stock_quantity=) && (p.stock_quantity.nil? || p.stock_quantity == 0)
    p.status          = 'active' if p.respond_to?(:status=) && p.status.blank?
    p.active          = true  if p.respond_to?(:active=) && p.active.nil?
    p.sku             = "#{p.name.parameterize.upcase}-#{SecureRandom.hex(3)}" if p.respond_to?(:sku=)

    begin
      p.save!
      demo_created += 1
      puts "Created demo product: #{p.name} (id: #{p.id})"

      imgs = sample_images_by_category[cat.name] || sample_images_by_category['default']
      img  = imgs.sample
      set_product_image(p, img)
    rescue => e
      puts "[seeds] Could not create demo product #{demo_name}: #{e.class} - #{e.message}"
      demo_created += 1
    end

    idx += 1
  end

  puts "Demo products created: #{to_create}"
else
  puts "No demo products required. Current products: #{current_total}"
end

puts "Seeding finished. Final Product count: #{Product.count}"