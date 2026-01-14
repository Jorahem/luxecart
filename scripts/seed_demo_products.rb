# scripts/seed_demo_products.rb
# Creates categories, brands and demo products (up to ~35 total).
# Robust: assigns category & brand BEFORE save and generates SKU when required.
#
# Run:
#   bin/rails runner scripts/seed_demo_products.rb
#
require 'open-uri'
require 'securerandom'

puts "Creating categories and brands..."
categories = %w[Furniture Lighting Decor Textiles Tables]
brands = ['LuxeHome', 'NordicDesign', 'StudioCraft', 'ModernHouse']

categories.each { |name| Category.find_or_create_by!(name: name) }
brands.each     { |name| Brand.find_or_create_by!(name: name) }
puts "Categories and Brands created."

# Curated product samples
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

sample_images_by_category = {
  'Furniture' => [
'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=1200&auto=format&fit=crop', // sofa
  'https://images.unsplash.com/photo-1501045661006-fcebe0257c3f?q=80&w=1200&auto=format&fit=crop', // living room
  'https://images.unsplash.com/photo-1493666438817-866a91353ca9?q=80&w=1200&auto=format&fit=crop', // interior decor
  'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop', // desk workspace
  'https://images.unsplash.com/photo-1550581190-9c1c48d21d6c?q=80&w=1200&auto=format&fit=crop', // modern room
  'https://images.unsplash.com/photo-1505691938895-1758d7feb511?q=80&w=1200&auto=format&fit=crop', // bedroom
  'https://images.unsplash.com/photo-1549187774-b4e9b0445b6b?q=80&w=1200&auto=format&fit=crop', // chair
  'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1200&auto=format&fit=crop', // minimal interior
  'https://images.unsplash.com/photo-1505692794400-7c6050b7c7d6?q=80&w=1200&auto=format&fit=crop', // couch
  'https://images.unsplash.com/photo-1505691723518-36a2bbf07e4d?q=80&w=1200&auto=format&fit=crop', // furniture set
  'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=1200&auto=format&fit=crop', // dining area
  'https://images.unsplash.com/photo-1554995207-c18c203602cb?q=80&w=1200&auto=format&fit=crop'  // luxury interior



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
    'https://images.unsplash.com/photo-1481277542470-605612bd2d61?q=80&w=1200&auto=format&fit=crop',





  "https://images.unsplash.com/photo-1505692794400-7c6050b7c7d6?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1481277542470-605612bd2d61?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1505691723518-36a2bbf07e4d?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1540574163026-643ea20ade25?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?q=80&w=1200&auto=format&fit=crop"





  ]
}

def set_product_image(product, image_url)
  return if image_url.blank?
  if Product.column_names.include?('image') && product.respond_to?(:image=)
    begin
      product.update_column(:image, image_url)
      return true
    rescue; end
  end

  if Product.column_names.include?('image_url') && product.respond_to?(:image_url=)
    begin
      product.update_column(:image_url, image_url)
      return true
    rescue; end
  end

  if product.respond_to?(:image) && product.image.respond_to?(:attach)
    begin
      io = URI.open(image_url)
      product.image.attach(io: io, filename: "#{product.name.parameterize}.jpg", content_type: io.content_type)
      return true
    rescue => e
      puts "[seeds] ActiveStorage attach failed for #{product.name}: #{e.class} - #{e.message}"
    end
  end

  if product.respond_to?(:images) && product.images.respond_to?(:attach)
    begin
      io = URI.open(image_url)
      product.images.attach(io: io, filename: "#{product.name.parameterize}.jpg", content_type: io.content_type)
      return true
    rescue => e
      puts "[seeds] ActiveStorage (images) attach failed for #{product.name}: #{e.class} - #{e.message}"
    end
  end

  puts "[seeds] No image setter available for Product #{product.name}; skipping image."
  false
end

puts "Seeding curated products..."
created = 0; updated = 0

products_data.each do |attrs|
  begin
    category = Category.find_by(name: attrs[:category])
    brand = Brand.find_by(name: attrs[:brand])

    unless category && brand
      puts "Skipping #{attrs[:name]}: missing category or brand"
      next
    end

    # Build product but ensure category & brand are assigned BEFORE save
    product = Product.find_or_initialize_by(name: attrs[:name])
    product.description = attrs[:description] if product.respond_to?(:description=)
    product.price = attrs[:price] if product.respond_to?(:price=)

    # assign associations (ensure these are set before save)
    if product.respond_to?(:category=)
      product.category = category
    elsif Product.column_names.include?('category_id')
      product.category_id = category.id
    end

    if product.respond_to?(:brand=)
      product.brand = brand
    elsif Product.column_names.include?('brand_id')
      product.brand_id = brand.id
    end

    # Ensure SKU exists if app requires it
    if product.respond_to?(:sku=) && product.sku.blank?
      product.sku = "#{product.name.parameterize.upcase}-#{SecureRandom.hex(3)}"
    end

    # sensible defaults
    product.track_inventory = true if product.respond_to?(:track_inventory=) && product.track_inventory.nil?
    product.stock_quantity = 100 if product.respond_to?(:stock_quantity=) && (product.stock_quantity.nil? || product.stock_quantity == 0)
    product.status = 'active' if product.respond_to?(:status=) && product.status.blank?

    # Save now that required associations/sku are present
    product.save!

    if product.previous_changes.key?('id')
      created += 1
    else
      updated += 1
    end

    set_product_image(product, attrs[:image]) if attrs[:image].present?
    puts "Created/updated product: #{product.name} (id: #{product.id})"
  rescue ActiveRecord::RecordInvalid => e
    puts "[seeds] Validation failed for #{attrs[:name]}: #{e.record.errors.full_messages.join(', ')}"
  rescue => e
    puts "[seeds] Failed to create #{attrs[:name]}: #{e.class} - #{e.message}"
  end
end

puts "Curated seeding done. Created: #{created}, Updated: #{updated}"

# Now create additional demo products until desired_total reached
desired_total = 35
current_total = Product.count
to_create = [0, desired_total - current_total].max

if to_create > 0
  puts "Creating #{to_create} additional demo products..."
  demo_created = 0
  category_records = Category.all.to_a
  brand_records = Brand.all.to_a
  idx = 0

  while demo_created < to_create
    cat = category_records[idx % category_records.length]
    brand = brand_records[idx % brand_records.length]
    seq = Product.where("name LIKE ?", "#{cat.name} Demo %").count + 1
    demo_name = "#{cat.name} Demo #{seq}"
    if Product.exists?(name: demo_name)
      idx += 1
      next
    end

    p = Product.new
    p.name = demo_name
    p.description = "Demo #{demo_name} — sample product for #{cat.name}."
    if p.respond_to?(:price=)
      p.price = ((20 + rand * 480) * 100).round / 100.0
    elsif p.respond_to?(:unit_price_decimal=)
      p.unit_price_decimal = ((20 + rand * 480) * 100).round / 100.0
    end

    # assign associations before save
    if p.respond_to?(:category=)
      p.category = cat
    elsif Product.column_names.include?('category_id')
      p.category_id = cat.id
    end

    if p.respond_to?(:brand=)
      p.brand = brand
    elsif Product.column_names.include?('brand_id')
      p.brand_id = brand.id
    end

    # SKU
    if p.respond_to?(:sku=)
      p.sku = "#{p.name.parameterize.upcase}-#{SecureRandom.hex(3)}"
    end

    p.track_inventory = true if p.respond_to?(:track_inventory=)
    p.stock_quantity = 50 if p.respond_to?(:stock_quantity=)
    p.status = 'active' if p.respond_to?(:status=)

    begin
      p.save!
      demo_created += 1
      puts "Created demo product: #{p.name} (id: #{p.id})"

      imgs = sample_images_by_category[cat.name] || sample_images_by_category.values.flatten
      img = imgs.sample
      set_product_image(p, img)
    rescue ActiveRecord::RecordInvalid => e
      puts "[seeds] Validation failed for demo #{demo_name}: #{e.record.errors.full_messages.join(', ')}"
      demo_created += 1
    rescue => e
      puts "[seeds] Could not create demo product #{demo_name}: #{e.class} - #{e.message}"
      demo_created += 1
    end

    idx += 1
  end

  puts "Demo products created: #{to_create}"
else
  puts "No additional demo products required. Current products: #{current_total}"
end

puts "Seeding finished. Final Product count: #{Product.count}"