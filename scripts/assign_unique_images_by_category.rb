# scripts/assign_more_images.rb
# Assigns varied Unsplash image_url values to products by category (rotating set).
# Run with:
#   bin/rails runner scripts/assign_more_images.rb

urls_by_category = {
  'Furniture' => [
    'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1505691723518-36a2bbf07e4d?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1540574163026-643ea20ade25?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1549187774-b4e9b0445b6b?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1505740106531-4243f3831b16?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1200&auto=format&fit=crop'
  ],
  
  'Lighting' => [
    'https://images.unsplash.com/photo-1505691723518-36a2b4d3f8f8?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1497032628192-86f99bcd76bc?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1531058020387-3be344556be6?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1496317556649-f930d733eea2?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1475688621402-4257d3a3d0b9?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1541631370684-0abbc6a47b58?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524758631624-2bcbb6b3f6d3?q=80&w=1200&auto=format&fit=crop'
  ],
  'Decor' => [
    'https://images.unsplash.com/photo-1493666438817-866a91353ca9?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1503602642458-232111445657?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1503602642590-902f1aeb7e3f?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1505691938895-1758d7feb511?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1481277542470-605612bd2d61?q=80&w=1200&auto=format&fit=crop'
  ],
  'Textiles' => [
    'https://images.unsplash.com/photo-1520975681500-99f9e6a7b3b8?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1505692794400-7c6050b7c7d6?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1503602642458-232111445657?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1496318447583-f524534e9ce1?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1520975681500-1234567890ab?q=80&w=1200&auto=format&fit=crop'
  ],
  'Tables' => [
    'https://images.unsplash.com/photo-1505692794400-7c6050b7c7d6?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1481277542470-605612bd2d61?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1540574163026-643ea20ade25?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1505740106531-4243f3831b16?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524758631624-a0c2b9c3e0f3?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1200&auto=format&fit=crop'
  ]
}

unless Product.column_names.include?('image_url')
  puts "No image_url column found. Run migration to add one first."
  exit 1
end

puts "Assigning images to products by category..."
counters = Hash.new(0)
Product.order(:id).find_each do |p|
  cat = p.try(:category).try(:name) || 'Furniture'
  arr = urls_by_category[cat] || urls_by_category.values.flatten
  next if arr.empty?
  counters[cat] += 1
  chosen = arr[(counters[cat]-1) % arr.length]
  p.update_column(:image_url, chosen)
  puts "Product #{p.id} (#{p.name}) => #{chosen}"
end
puts "Done assigning images."