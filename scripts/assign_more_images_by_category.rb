# scripts/assign_more_images.rb
# Assigns varied Unsplash image_url values to products by category (rotating set).
# Run with:
#   bin/rails runner scripts/assign_more_images.rb
#
# This updated script provides 15 image URLs per category (uses Unsplash source endpoints
# to generate distinct images via the `sig` parameter). It reuses the same filename and
# behavior as your previous script but expands categories and images as requested.
#
require 'open-uri'

urls_by_category = {
  'Accessories' => (1..15).map { |i| "https://source.unsplash.com/1200x800/?accessories,bags,jewelry,style&sig=#{i}" },
  'Clothing'    => (1..15).map { |i| "https://source.unsplash.com/1200x800/?clothing,fashion,apparel,outfit&sig=#{i}" },
  'Men'         => (1..15).map { |i| "https://source.unsplash.com/1200x800/?men-fashion,menswear,suit,men&sig=#{i}" },
  'Women'       => (1..15).map { |i| "https://source.unsplash.com/1200x800/?women-fashion,womenswear,dress,style&sig=#{i}" },
  'Children'    => (1..15).map { |i| "https://source.unsplash.com/1200x800/?kids-fashion,children,kids,playful&sig=#{i}" },
  'Decor'       => (1..15).map { |i| "https://source.unsplash.com/1200x800/?home-decor,interior,decor,ornament&sig=#{i}" },
  'Furniture'   => (1..15).map { |i| "https://source.unsplash.com/1200x800/?furniture,sofa,chair,interior&sig=#{i}" },
  'Lighting'    => (1..15).map { |i| "https://source.unsplash.com/1200x800/?lighting,lamps,pendant,ambient&sig=#{i}" },
  'New Arrivals'=> (1..15).map { |i| "https://source.unsplash.com/1200x800/?new-arrivals,collection,new,launch&sig=#{i}" },
  'Sale'        => (1..15).map { |i| "https://source.unsplash.com/1200x800/?sale,discount,clearance,shopping&sig=#{i}" },
  'Shoes'       => (1..15).map { |i| "https://source.unsplash.com/1200x800/?shoes,sneakers,heels,footwear&sig=#{i}" },
  'Tables'      => (1..15).map { |i| "https://source.unsplash.com/1200x800/?table,dining-table,coffee-table,wooden-table&sig=#{i}" },
  'Textiles'    => (1..15).map { |i| "https://source.unsplash.com/1200x800/?textiles,fabrics,woven,linen&sig=#{i}" },
  'Underwear'   => (1..15).map { |i| "https://source.unsplash.com/1200x800/?underwear,lingerie,intimates,underwear-fashion&sig=#{i}" }
}

unless Product.column_names.include?('image_url')
  puts "No image_url column found. Run migration to add one first."
  exit 1
end

puts "Assigning images to products by category (15-image sets available)..."

# Counters track used index per category so assignment rotates deterministically
counters = Hash.new(0)

Product.order(:id).find_each do |p|
  # Determine category name key used in mapping
  cat_name = p.try(:category).try(:name)

  # Normalize some common variants to our keys in urls_by_category
  normalized =
    case cat_name&.strip
    when nil, ''
      'Furniture'                 # fallback
    when /accessor/i
      'Accessories'
    when /\bcloth/i
      'Clothing'
    when /\bmen\b/i
      'Men'
    when /\bwomen\b/i
      'Women'
    when /\bchild/i, /\bkid/i
      'Children'
    when /decor/i
      'Decor'
    when /furnitur/i
      'Furniture'
    when /light/i
      'Lighting'
    when /new arr/i, /new-arr/i, /newarr/i
      'New Arrivals'
    when /sale/i
      'Sale'
    when /shoe/i
      'Shoes'
    when /table/i
      'Tables'
    when /textil/i, /fabric/i
      'Textiles'
    when /underwear|lingerie|intimate/i
      'Underwear'
    else
      # If the exact category name matches one of our keys, use it directly
      if urls_by_category.key?(cat_name)
        cat_name
      else
        # fallback: try capitalized variants
        candidate = cat_name.to_s.titleize rescue nil
        if candidate && urls_by_category.key?(candidate)
          candidate
        else
          'Furniture'
        end
      end
    end

  arr = urls_by_category[normalized] || urls_by_category.values.flatten
  next if arr.empty?

  counters[normalized] += 1
  chosen = arr[(counters[normalized] - 1) % arr.length]

  begin
    p.update_column(:image_url, chosen)
    puts "Product #{p.id} (#{p.name}) [#{normalized}] => #{chosen}"
  rescue => e
    puts "[WARN] Failed to update Product #{p.id} (#{p.name}): #{e.class} - #{e.message}"
  end
end

puts "Done assigning images to products. For reference, each category has 15 image URLs in this script."