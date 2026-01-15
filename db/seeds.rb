# db/seeds.rb
# Creates categories, brands and products safely (handles string image columns or ActiveStorage attachments).
# Extends your existing seed set with additional demo products up to ~35 total.
#
# Usage:
#   bin/rails db:seed
# or (if you prefer runner)
#   bin/rails runner db/seeds.rb
#
require 'open-uri'
require 'securerandom'

puts "Seeding categories and brands..."

categories = %w[Furniture Lighting Decor Textiles Tables]
brands = ['LuxeHome', 'NordicDesign', 'StudioCraft', 'ModernHouse']

categories.each do |name|
  Category.find_or_create_by!(name: name)
end

brands.each do |name|
  Brand.find_or_create_by!(name: name)
end

puts "Categories and Brands created."

# Initial curated product data you already had (kept as-is)
products_data = [
  { name: 'Luxe Velvet Chair', description: 'Plush velvet lounge chair with solid wood legs.', price: 249.99, image: 'https://images.unsplash.com/photo-1549187774-b4e9b0445b6b?q=80&w=1200&auto=format&fit=crop', category: 'Furniture', brand: 'LuxeHome' },
  { name: 'Modern Floor Lamp', description: 'Sleek metal floor lamp with dimmable LED.', price: 89.50, image: 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?q=80&w=1200&auto=format&fit=crop', category: 'Lighting', brand: 'NordicDesign' },
  { name: 'Handwoven Rug', description: 'Handwoven area rug with geometric patterns.', price: 199.95, image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1200&auto=format&fit=crop', category: 'Decor', brand: 'StudioCraft' },
  { name: 'Oak Coffee Table', description: 'Solid oak coffee table with minimalist finish.', price: 159.00, image: 'https://images.unsplash.com/photo-1505691723518-36a2bbf07e4d?q=80&w=1200&auto=format&fit=crop', category: 'Tables', brand: 'ModernHouse' },
  { name: 'Ceramic Vase Set', description: 'Artisan ceramic vases in three sizes.', price: 49.99, image: 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop', category: 'Decor', brand: 'StudioCraft' },
  { name: 'Luxe Bed Linen', description: 'Egyptian cotton bed linen for luxurious sleep.', price: 129.00, image: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1200&auto=format&fit=crop', category: 'Textiles', brand: 'LuxeHome' },
  { name: 'Minimalist Bookshelf', description: 'Floating bookshelf with clean lines.', price: 179.99, image: 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop', category: 'Furniture', brand: 'NordicDesign' },
  { name: 'Designer Throw Pillow', description: 'Soft throw pillow with handcrafted cover.', price: 29.99, image: 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop', category: 'Textiles', brand: 'StudioCraft' },
  { name: 'Contemporary Wall Art', description: 'Framed print with abstract composition.', price: 89.00, image: 'https://images.unsplash.com/photo-1505691723518-36a2bbf07e4d?q=80&w=1200&auto=format&fit=crop', category: 'Decor', brand: 'ModernHouse' },
  { name: 'Nordic Dining Chair', description: 'Comfortable dining chair with tapered legs.', price: 99.00, image: 'https://images.unsplash.com/photo-1549187774-b4e9b0445b6b?q=80&w=1200&auto=format&fit=crop', category: 'Furniture', brand: 'NordicDesign' }
]

# Additional sample images per category (used for generated demo products)
sample_images_by_category = {
  'Furniture' => [
    'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1501045661006-fcebe0257c3f?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1493666438817-866a91353ca9?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1550581190-9c1c48d21d6c?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1505691938895-1758d7feb511?q=80&w=1200&auto=format&fit=crop'
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
  ]
}

puts "Seeding products (initial curated list)..."

created = 0
updated = 0

# Helper to attach/set image using available strategy
def set_product_image(product, image_url)
  return if image_url.blank?

  # Strategy A: string column 'image'
  if Product.column_names.include?('image') && product.respond_to?(:image=)
    begin
      product.update_column(:image, image_url)
      return true
    rescue
      # fall through
    end
  end

  # Strategy B: string column 'image_url'
  if Product.column_names.include?('image_url') && product.respond_to?(:image_url=)
    begin
      product.update_column(:image_url, image_url)
      return true
    rescue
      # fall through
    end
  end

  # Strategy C: ActiveStorage single attachment named `image`
  if product.respond_to?(:image) && product.image.respond_to?(:attach)
    begin
      io = URI.open(image_url)
      product.image.attach(io: io, filename: "#{product.name.parameterize}.jpg", content_type: io.content_type)
      return true
    rescue => e
      puts "[seeds] ActiveStorage attach failed for #{product.name}: #{e.class} - #{e.message}"
    end
  end

  # Strategy D: ActiveStorage collection `images`
  if product.respond_to?(:images) && product.images.respond_to?(:attach)
    begin
      io = URI.open(image_url)
      product.images.attach(io: io, filename: "#{product.name.parameterize}.jpg", content_type: io.content_type)
      return true
    rescue => e
      puts "[seeds] ActiveStorage (images) attach failed for #{product.name}: #{e.class} - #{e.message}"
    end
  end

  # No strategy worked
  puts "[seeds] No image setter available for Product #{product.name}; skipping image."
  false
end

products_data.each do |attrs|
  begin
    category = Category.find_by(name: attrs[:category])
    brand = Brand.find_by(name: attrs[:brand])

    unless category && brand
      puts "Skipping #{attrs[:name]}: missing category or brand (#{attrs[:category]}, #{attrs[:brand]})"
      next
    end

    product = Product.find_or_initialize_by(name: attrs[:name])
    # track whether this is new or updated
    new_record = product.new_record?

    product.description = attrs[:description] if product.respond_to?(:description=)
    product.price = attrs[:price] if product.respond_to?(:price=)
    product.category = category if product.respond_to?(:category=)
    product.brand = brand if product.respond_to?(:brand=)

    # generate SKU if required
    if product.respond_to?(:sku=) && product.sku.blank?
      product.sku = "#{product.name.parameterize.upcase}-#{SecureRandom.hex(3)}"
    end

    # set sensible defaults for common fields if they exist
    product.track_inventory = true if product.respond_to?(:track_inventory=) && product.track_inventory.nil?
    product.stock_quantity = 100 if product.respond_to?(:stock_quantity=) && (product.stock_quantity.nil? || product.stock_quantity == 0)
    product.status = 'active' if product.respond_to?(:status=) && product.status.blank?

    product.save!
    if new_record
      created += 1
    else
      updated += 1
    end

    image_url = attrs[:image]
    if image_url.present?
      begin
        set_product_image(product, image_url)
      rescue => e
        puts "[seeds] Image attach/set failed for #{product.name}: #{e.class} - #{e.message}"
      end
    end

    puts "Created/updated product: #{product.name} (SKU: #{product.try(:sku)})"
  rescue ActiveRecord::RecordInvalid => e
    puts "[seeds] Validation failed for #{attrs[:name]}: #{e.record.errors.full_messages.join(', ')}"
  rescue => e
    puts "[seeds] Failed to create #{attrs[:name]}: #{e.class} - #{e.message}"
  end
end

puts "Initial curated products seeded. Created: #{created}, Updated: #{updated}"

# Now: generate additional demo products so total products >= desired_total
desired_total = 35
current_total = Product.count
to_create = [0, desired_total - current_total].max

if to_create > 0
  puts "Creating #{to_create} additional demo products to reach #{desired_total} total..."
  demo_created = 0

  # Use categories list to distribute products
  category_records = Category.all.to_a
  brand_records = Brand.all.to_a

  idx = 0
  while demo_created < to_create
    cat = category_records[idx % category_records.length]
    brand = brand_records[idx % brand_records.length]
    seq = (Product.where("name LIKE ?", "#{cat.name} Demo %").count + 1)

    demo_name = "#{cat.name} Demo #{seq}"
    # Avoid duplicate names just in case
    next if Product.exists?(name: demo_name)

    description = "Demo #{demo_name} — sample product created by seeds for category #{cat.name}."
    price = ((20 + rand * 480) * 100).round / 100.0

    p = Product.new
    p.name = demo_name
    p.description = description if p.respond_to?(:description=)
    if p.respond_to?(:price=)
      p.price = price
    elsif p.respond_to?(:unit_price_decimal=)
      p.unit_price_decimal = price
    end

    # associate
    p.category = cat if p.respond_to?(:category=)
    p.brand = brand if p.respond_to?(:brand=)

    # defaults
    p.track_inventory = true if p.respond_to?(:track_inventory=) && p.track_inventory.nil?
    p.stock_quantity = 50 if p.respond_to?(:stock_quantity=) && (p.stock_quantity.nil? || p.stock_quantity == 0)
    p.status = 'active' if p.respond_to?(:status=) && p.status.blank?

    # SKU
    if p.respond_to?(:sku=)
      p.sku = "#{p.name.parameterize.upcase}-#{SecureRandom.hex(3)}"
    end

    begin
      p.save!
      demo_created += 1
      puts "Created demo product: #{p.name} (id: #{p.id})"

      # pick an image for this category
      imgs = sample_images_by_category[cat.name] || sample_images_by_category.values.flatten
      img = imgs.sample

      begin
        set_product_image(p, img)
      rescue => e
        puts "[seeds] Failed to attach image for demo #{p.name}: #{e.class} - #{e.message}"
      end
    rescue => e
      puts "[seeds] Could not create demo product #{demo_name}: #{e.class} - #{e.message}"
      # avoid infinite loops: increment demo_created anyway to progress
      demo_created += 1
    end

    idx += 1
  end

  puts "Demo products created: #{to_create}"
else
  puts "No additional demo products required. Current products: #{current_total}"
end

puts "Seeding finished. Final Product count: #{Product.count}"