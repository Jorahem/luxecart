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
# NOTE: Use a normal array so multi-word names like "New Arrivals" are preserved.
base_categories = [
  'Furniture', 'Lighting', 'Decor', 'Textiles', 'Tables',
  'Accessories', 'Shoes', 'Underwear', 'New Arrivals', 'Sale','Smartwatch'
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
products_data = [
  { name: 'Luxe Velvet Chair',    description: 'Plush velvet lounge chair with solid wood legs.', price: 249.99, image: 'https://images.unsplash.com/photo-1549187774-b4e9b0445b6b?q=80&w=1200&auto=format&fit=crop', category: 'Furniture', brand: 'LuxeHome' },
  { name: 'Modern Floor Lamp',    description: 'Sleek metal floor lamp with dimmable LED.', price: 89.50,  image: 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?q=80&w=1200&auto=format&fit=crop', category: 'Lighting',  brand: 'NordicDesign' },
  { name: 'Handwoven Rug',       description: 'Handwoven area rug with geometric patterns.', price: 199.95, image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1200&auto=format&fit=crop', category: 'Decor', brand: 'StudioCraft' },
  { name: 'Oak Coffee Table',     description: 'Solid oak coffee table with minimalist finish.', price: 159.00, image: 'https://images.unsplash.com/photo-1505691723518-36a2bbf07e4d?q=80&w=1200&auto=format&fit=crop', category: 'Tables', brand: 'ModernHouse' },
  { name: 'Ceramic Vase Set',     description: 'Artisan ceramic vases in three sizes.', price: 49.99, image: 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop', category: 'Decor', brand: 'StudioCraft' },
  { name: 'Luxe Bed Linen',      description: 'Egyptian cotton bed linen for luxurious sleep.', price: 129.00, image: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1200&auto=format&fit=crop', category: 'Textiles', brand: 'LuxeHome' },
  { name: 'Minimalist Bookshelf', description: 'Floating bookshelf with clean lines.', price: 179.99, image: 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop', category: 'Furniture', brand: 'NordicDesign' },
  { name: 'Designer Throw Pillow', description: 'Soft throw pillow with handcrafted cover.', price: 29.99, image: 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop', category: 'Textiles', brand: 'StudioCraft' },
  { name: 'Contemporary Wall Art', description: 'Framed print with abstract composition.', price: 89.00, image: 'https://images.unsplash.com/photo-1505691723518-36a2bbf07e4d?q=80&w=1200&auto=format&fit=crop', category: 'Decor', brand: 'ModernHouse' },
  { name: 'Nordic Dining Chair',   description: 'Comfortable dining chair with tapered legs.', price: 99.00, image: 'https://images.unsplash.com/photo-1549187774-b4e9b0445b6b?q=80&w=1200&auto=format&fit=crop', category: 'Furniture', brand: 'NordicDesign' }
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
    'https://images.unsplash.com/photo-1505691723518-36a2b4d3f8f8?q=80&w=1200&auto=format&fit=crop',
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
    brand = Brand.find_by(name: attrs[:brand])

    unless category && brand
      puts "Skipping #{attrs[:name]}: missing category or brand (#{attrs[:category]}, #{attrs[:brand]})"
      next
    end

    product = Product.find_or_initialize_by(name: attrs[:name])
    new_record = product.new_record?

    product.description = attrs[:description] if product.respond_to?(:description=)
    product.price = attrs[:price] if product.respond_to?(:price=)
    product.category = category if product.respond_to?(:category=)
    product.brand = brand if product.respond_to?(:brand=)

    # generate SKU if model supports it
    if product.respond_to?(:sku=) && product.sku.blank?
      product.sku = "#{product.name.parameterize.upcase}-#{SecureRandom.hex(3)}"
    end

    # sensible defaults
    product.track_inventory = true if product.respond_to?(:track_inventory=) && product.track_inventory.nil?
    product.stock_quantity = 100 if product.respond_to?(:stock_quantity=) && (product.stock_quantity.nil? || product.stock_quantity.zero?)
    product.status = 'active' if product.respond_to?(:status=) && product.status.blank?
    product.active = true if product.respond_to?(:active=) && product.active.nil?

    product.save!
    if new_record
      created += 1
    else
      updated += 1
    end

    # attach/set image - support either :image or :image_url from data
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
# 6) Explicit collections (Men/Women/Children/Shoes/Decor/...) — ensure Brand exists
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
   
    { name: "Playtime T-Shirt", price: 14.99, image_url: "https://poppyplaytime.com/cdn/shop/files/W5O053A_1.jpg?v=1722976528&width=1600", description: "Durable cotton t-shirt for playtime and school." },
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
    { name: "Minimal Leather Sneaker", price: 89.00, image_url: "https://images.opumo.com/wordpress/wp-content/uploads/2021/12/opumo-minimalist-sneakers_0003_243762625_355617166345206_1099814619160939813_n.jpg", description: "Timeless leather sneakers — everyday staple." },
    { name: "Chukka Boot", price: 119.00, image_url: "https://www.cheaney.co.uk/blog/wp-content/uploads/2025/04/chukka-boots-700x467-2.jpg", description: "Rugged chukka boot with refined profile." },
    { name: "Classic Running Shoes", price: 59.99, image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80", description: "Lightweight running shoes designed for daily workouts." },
{ name: "Men's Casual Sneakers", price: 49.99, image_url: "https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=800&q=80", description: "Comfortable sneakers for everyday casual wear." },
{ name: "Women's White Sneakers", price: 54.99, image_url: "https://img.drz.lazcdn.com/static/np/p/f744a0a5f49fe877cac8dece03851982.jpg_720x720q80.jpg", description: "Trendy white sneakers with a clean modern look." },
{ name: "Formal Leather Shoes", price: 79.99, image_url: "https://images.unsplash.com/photo-1521336575822-6da63fb45455?auto=format&fit=crop&w=800&q=80", description: "Premium leather shoes suitable for office and events." },
{ name: "Men's Loafers", price: 64.99, image_url: "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=800&q=80", description: "Slip-on loafers for comfort and style." },
{ name: "Women's Heels", price: 69.99, image_url: "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=800&q=80", description: "Elegant heels perfect for parties and formal occasions." },
{ name: "Kids Sports Shoes", price: 39.99, image_url: "https://image.made-in-china.com/202f0j00YMHiIfNJhpuq/New-Style-Baby-Shoes-for-Boys-Sports-Shoes-Girls-Light-Weight-Running-Kids-Sneakers.webp", description: "Durable sports shoes designed for active kids." },
{ name: "Canvas Shoes", price: 34.99, image_url: "https://i.ebayimg.com/images/g/15oAAOSw2OtnA7Is/s-l1200.jpg", description: "Breathable canvas shoes for daily casual use." },
{ name: "Hiking Boots", price: 89.99, image_url: "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?auto=format&fit=crop&w=800&q=80", description: "Rugged boots built for outdoor adventures." },
{ name: "Slip-On Casual Shoes", price: 44.99, image_url: "https://images.unsplash.com/photo-1511556532299-8f662fc26c06?auto=format&fit=crop&w=800&q=80", description: "Easy slip-on shoes for quick and comfortable wear." },
{ name: "Women's Sandals", price: 29.99, image_url: "https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=800&q=80", description: "Open-toe sandals ideal for summer days." },
{ name: "Men's Flip Flops", price: 19.99, image_url: "https://images.unsplash.com/photo-1605733160314-4fc7dac4bb16?auto=format&fit=crop&w=800&q=80", description: "Lightweight flip flops for casual comfort." },
{ name: "Kids School Shoes", price: 32.99, image_url: "https://i5.walmartimages.com/asr/b3292571-40e4-4dc6-8209-a74766a1257f.4f6cc8908cb5998827aa5ed8de5f4125.jpeg", description: "Sturdy school shoes designed for daily use." },
{ name: "Ankle Boots", price: 74.99, image_url: "https://img.drz.lazcdn.com/static/np/p/fa5b3626ea44c742268b46591c81677c.jpg_720x720q80.jpg_.webp", description: "Stylish ankle boots for a bold fashion statement." },
{ name: "Sports Training Shoes", price: 64.99, image_url: "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&w=800&q=80", description: "Training shoes built for flexibility and grip." }

  ],

  "Decor" => [
    { name: "Designer Throw Pillow", price: 34.99, image_url: "https://images.unsplash.com/photo-1505691723518-36a5ac3be353?auto=format&fit=crop&w=800&q=80", description: "Plush throw pillow in seasonal colours." },
    { name: "Wall Art Print", price: 79.00, image_url: "https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=800&q=80", description: "70x50cm framed art print for living room." }
  ],

  "Furniture" => [
    { name: "Nordic Dining Chair", price: 129.00, image_url: "https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=800&q=80", description: "Clean-lined dining chair with comfortable seat." },
    { name: "Accent Armchair", price: 249.99, image_url: "https://images.unsplash.com/photo-1493666438817-866a91353ca9?auto=format&fit=crop&w=800&q=80", description: "Cozy accent chair for reading corners." }
  ],

  "Lighting" => [
    { name: "Pendant Lamp", price: 129.00, image_url: "https://images.unsplash.com/photo-1505691723518-11a9f8a6a1df?auto=format&fit=crop&w=800&q=80", description: "Brass pendant to lift your dining area." },
    { name: "Table Lamp", price: 69.00, image_url: "https://images.unsplash.com/photo-1524758631624-7b5d2d1b9e0a?auto=format&fit=crop&w=800&q=80", description: "Soft-diffuse table lamp for bedside." }
  ],


"Accessories" => [
  {
    name: "Leather Belt",
    price: 24.99,
    image_url: "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80",
    description: "Classic leather belt for formal and casual outfits."
  },
  {
    name: "Stylish Sunglasses",
    price: 39.99,
    image_url: "https://images.unsplash.com/photo-1514996937319-344454492b37?auto=format&fit=crop&w=800&q=80",
    description: "UV-protected sunglasses—ideal for summer and travel."
  },
  {
    name: "Luxury Watch",
    price: 119.00,
    image_url: "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80",
    description: "Elegant watch to elevate your everyday look."
  },
  {
    name: "Wool Scarf",
    price: 28.99,
    image_url: "https://images.unsplash.com/photo-1506765515384-028b60a970df?auto=format&fit=crop&w=800&q=80",
    description: "Warm wool scarf available in seasonal colors."
  },
  {
    name: "Canvas Tote Bag",
    price: 19.50,
    image_url: "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=800&q=80",
    description: "Eco-friendly canvas tote—perfect for shopping or travel."
  }
],


"New Arrivals" => [
  {
    name: "Summer Cotton Kurta",
    price: 23.99,
    image_url: "https://images.unsplash.com/photo-1523381213953-0d0a5f2a0d1c?auto=format&fit=crop&w=800&q=80",
    description: "Light, breezy kurta for sunny days."
  },
  {
    name: "Tailored Blazer",
    price: 89.99,
    image_url: "https://images.unsplash.com/photo-1592878849122-3f8b8f82cda8?auto=format&fit=crop&w=800&q=80",
    description: "Sharp blazer perfect for office meetings."
  },
  {
    name: "Floral Midi Dress",
    price: 42.99,
    image_url: "https://images.unsplash.com/photo-1520975682031-a9c3c8c23e36?auto=format&fit=crop&w=800&q=80",
    description: "Elegant floral dress for daytime occasions."
  },
  {
    name: "Kids Printed Hoodie",
    price: 27.99,
    image_url: "https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=800&q=80",
    description: "Cartoon print hoodie for fun and warmth."
  },
  {
    name: "Cotton Button-Up Shirt",
    price: 33.99,
    image_url: "https://images.unsplash.com/photo-1520975916090-3105956dac38?auto=format&fit=crop&w=800&q=80",
    description: "Modern cotton shirt, easy for work and leisure."
  }
],


  "Tables" => [
    { name: "Dining Table", price: 599.00, image_url: "https://images.unsplash.com/photo-1519710164239-481f0a6c0c3b?auto=format&fit=crop&w=800&q=80", description: "Solid wood dining table, seats 6." },
    { name: "Side Table", price: 89.00, image_url: "https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=800&q=80", description: "Compact side table for small spaces." }
  ],

  "Textiles" => [
    { name: "Woven Throw", price: 49.00, image_url: "https://images.unsplash.com/photo-1523381213953-0d0a5f2a0d1c?auto=format&fit=crop&w=800&q=80", description: "Cozy throw blanket in woven cotton." },
    { name: "Decorative Rug", price: 249.00, image_url: "https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=800&q=80", description: "Hand-loomed rug for living spaces." }
  ],

  "Sale" => [
    { name: "Seasonal Tee (Sale)", price: 9.99, image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80", description: "Basic tee at a special price." },
    { name: "Denim Jacket (Sale)", price: 59.99, image_url: "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=800&q=80", description: "Denim jacket with a markdown price." }
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
    {name:"Smart Fitness Watch",price:79.99,image_url:"https://img.drz.lazcdn.com/static/np/p/72f3041de192a935952b815f254e41cd.jpg_720x720q80.jpg",description:"Fitness smartwatch with heart rate and step tracking."},
{name:"Classic Digital Smartwatch",price:69.99,image_url:"https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80",description:"Sleek digital smartwatch with daily activity monitoring."},
{name:"Sport Pro Smartwatch",price:89.99,image_url:"https://images.unsplash.com/photo-1544117519-31a4b719223d?auto=format&fit=crop&w=800&q=80",description:"Rugged smartwatch designed for sports and workouts."},
{name:"Luxury Metal Smartwatch",price:129.99,image_url:"https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?auto=format&fit=crop&w=800&q=80",description:"Premium metal smartwatch with elegant design."},
{name:"Minimal Touch Smartwatch",price:59.99,image_url:"https://s.alicdn.com/@sc04/kf/Hbfece0be560946c3afb7e211f86635d5M/H9-Simple-Sports-Health-Tracker-Bluetooth-Smart-Watch-TFT-HD-Touch-Screen-Multi-function-Heart-Rate-Monitoring-Electronic-Watch.jpg",description:"Minimal smartwatch with touch display."},
{name:"Health Monitor Smartwatch",price:99.99,image_url:"https://images.unsplash.com/photo-1579586337278-3befd40fd17a?auto=format&fit=crop&w=800&q=80",description:"Advanced health monitoring smartwatch."},
{name:"Kids Smartwatch",price:49.99,image_url:"https://i0.wp.com/bestdealsnepal.com.np/wp-content/uploads/2019/08/gps-kids-watch.jpg?fit=500%2C500&ssl=1",description:"Smartwatch designed especially for kids."},
{name:"Outdoor Adventure Smartwatch",price:149.99,image_url:"https://res.garmin.com/subcategory/WW/GYM/GYM-CARD-INSTINCT-3.png",description:"GPS-enabled smartwatch for outdoor adventures."},
{name:"Slim Band Smartwatch",price:54.99,image_url:"https://images.mobilefun.co.uk/graphics/450pixelp/97908.jpg",description:"Slim and lightweight smartwatch band."},
{name:"AMOLED Display Smartwatch",price:119.99,image_url:"https://img.drz.lazcdn.com/static/np/p/2b0630bd654379394adca53cebd275a4.jpg_720x720q80.jpg",description:"Smartwatch with vibrant AMOLED display."}

  ]

}

puts "Seeding explicit collections..."

collections.each do |cat_name, items|
  cat = Category.find_or_create_by!(name: cat_name)

  items.each do |attrs|
    prod = Product.find_or_initialize_by(name: attrs[:name])

    prod.description = attrs[:description] if prod.respond_to?(:description=)
    prod.price = attrs[:price] if prod.respond_to?(:price=)
    prod.category = cat if prod.respond_to?(:category=)

    # Pick or create a brand:
    chosen_brand = nil
    if attrs[:brand].present?
      chosen_brand = Brand.find_or_create_by!(name: attrs[:brand])
    end
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
desired_total = 35
current_total = Product.count
to_create = [0, desired_total - current_total].max

if to_create > 0
  puts "Creating #{to_create} demo products to reach #{desired_total} total..."
  demo_created = 0
  category_records = Category.all.to_a
  brand_records = Brand.all.to_a
  idx = 0

  while demo_created < to_create
    cat = category_records[idx % category_records.length]
    brand = brand_records[idx % brand_records.length]
    seq = Product.where("name LIKE ?", "#{cat.name} Demo %").count + 1
    demo_name = "#{cat.name} Demo #{seq}"

    next if Product.exists?(name: demo_name)

    p = Product.new
    p.name = demo_name
    p.description = "Demo #{demo_name} — sample product created by seeds for category #{cat.name}." if p.respond_to?(:description=)
    price = (((20 + rand * 480) * 100).round) / 100.0
    if p.respond_to?(:price=)
      p.price = price
    elsif p.respond_to?(:unit_price_decimal=)
      p.unit_price_decimal = price
    end

    p.category = cat if p.respond_to?(:category=)
    p.brand = brand if p.respond_to?(:brand=)
    p.track_inventory = true if p.respond_to?(:track_inventory=) && p.track_inventory.nil?
    p.stock_quantity = 50 if p.respond_to?(:stock_quantity=) && (p.stock_quantity.nil? || p.stock_quantity == 0)
    p.status = 'active' if p.respond_to?(:status=) && p.status.blank?
    p.active = true if p.respond_to?(:active=) && p.active.nil?
    p.sku = "#{p.name.parameterize.upcase}-#{SecureRandom.hex(3)}" if p.respond_to?(:sku=)

    begin
      p.save!
      demo_created += 1
      puts "Created demo product: #{p.name} (id: #{p.id})"

      imgs = sample_images_by_category[cat.name] || sample_images_by_category['default']
      img = imgs.sample
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