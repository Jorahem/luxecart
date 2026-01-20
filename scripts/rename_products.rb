# scripts/rename_products.rb
# Run with:
#   bin/rails runner scripts/rename_products.rb
#
# This script does two things:
# 1) Prints every product: ID, current name, image URL
# 2) Lets you easily change names by editing the NEW_NAMES hash

puts "\n== CURRENT PRODUCTS (ID, Name, Image URL) ==\n\n"

Product.order(:id).each do |p|
  image =
    if p.respond_to?(:image_url) && p.image_url.present?
      p.image_url
    elsif p.respond_to?(:image) && p.image.is_a?(String)
      p.image
    else
      "(no image url column)"
    end

  puts "ID:    #{p.id}"
  puts "Name:  #{p.name}"
  puts "Image: #{image}"
  puts "-" * 60
end

############################################################
# EDIT BELOW TO RENAME PRODUCTS
#
# 1. Run this file once (see Step 3).
# 2. Look at the printed list. For each product you want
#    to rename, note its ID.
# 3. Put id => "New Name" inside NEW_NAMES.
############################################################

NEW_NAMES = {
  # Example (change these to what you want):
  # 11 => "Royal Dining Table",
  # 12 => "Modern White Table",
  # 13 => "Office Work Desk",
  # 14 => "Glass Coffee Table",
  # 15 => "Oak Coffee Table"

  33=> "Royal Dining Table",
  34 => "Biiilu",
  35 => "Hem jora"
}

if NEW_NAMES.any?
  puts "\n== RENAMING PRODUCTS ==\n\n"
  NEW_NAMES.each do |id, new_name|
    product = Product.find_by(id: id)
    if product
      old = product.name
      product.update!(name: new_name)
      puts "ID #{id}: '#{old}' -> '#{new_name}'"
    else
      puts "ID #{id}: product not found (skipped)"
    end
  end
  puts "\nDone. Refresh your website to see new names."
else
  puts "\nNEW_NAMES is empty. No names were changed."
  puts "To rename, edit scripts/rename_products.rb and fill NEW_NAMES."
end