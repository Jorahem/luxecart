# db/seeds.rb
# Creates categories, brands and products safely (handles string image columns or ActiveStorage attachments).
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

puts "Seeding products..."

products_data.each do |attrs|
  begin
    category = Category.find_by(name: attrs[:category])
    brand = Brand.find_by(name: attrs[:brand])

    unless category && brand
      puts "Skipping #{attrs[:name]}: missing category or brand (#{attrs[:category]}, #{attrs[:brand]})"
      next
    end

    product = Product.find_or_initialize_by(name: attrs[:name])
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

    # Save product (will raise if validations fail)
    product.save!

    image_url = attrs[:image]
    begin
      # Strategy A: string column 'image' or 'image_url'
      if Product.column_names.include?('image') && product.respond_to?(:image=)
        product.update_column(:image, image_url)
      elsif Product.column_names.include?('image_url') && product.respond_to?(:image_url=)
        product.update_column(:image_url, image_url)

      # Strategy B: ActiveStorage attachments
      elsif product.respond_to?(:image) && product.image.respond_to?(:attach)
        file = URI.open(image_url)
        product.image.attach(io: file, filename: "#{product.name.parameterize}.jpg")
      elsif product.respond_to?(:images) && product.images.respond_to?(:attach)
        file = URI.open(image_url)
        product.images.attach(io: file, filename: "#{product.name.parameterize}.jpg")
      else
        puts "[seeds] No image setter for Product; skipped image for #{product.name}"
      end
    rescue => e
      puts "[seeds] Image attach/set failed for #{product.name}: #{e.class} - #{e.message}"
    end

    puts "Created/updated product: #{product.name} (SKU: #{product.sku})"
  rescue ActiveRecord::RecordInvalid => e
    puts "[seeds] Validation failed for #{attrs[:name]}: #{e.record.errors.full_messages.join(', ')}"
  rescue => e
    puts "[seeds] Failed to create #{attrs[:name]}: #{e.class} - #{e.message}"
  end
end

puts "Seeding finished."