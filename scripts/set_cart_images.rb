# scripts/set_cart_images.rb
# Run with:
#   bin/rails runner scripts/set_cart_images.rb
#
# This sets image_url (or image string) for specific products so
# the cart can display their images.

PRODUCT_IMAGE_UPDATES = {
  # Fill with: id => "image-url"
  # Example (replace IDs and URLs with your own):
  # 11 => "https://images.unsplash.com/photo-1505691723518-36a2bbf07e4d?q=80&w=1200&auto=format&fit=crop",
  # 12 => "https://images.unsplash.com/photo-1549187774-b4e9b0445b6b?q=80&w=1200&auto=format&fit=crop",
  # 13 => "https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop"
}

if PRODUCT_IMAGE_UPDATES.empty?
  puts "PRODUCT_IMAGE_UPDATES is empty. Edit scripts/set_cart_images.rb and add id => url pairs."
  exit
end

PRODUCT_IMAGE_UPDATES.each do |id, url|
  product = Product.find_by(id: id)
  unless product
    puts "Product ID #{id} not found, skipping."
    next
  end

  old =
    if product.respond_to?(:image_url) && product.image_url.present?
      product.image_url
    elsif product.respond_to?(:image) && product.image.is_a?(String)
      product.image
    else
      nil
    end

  if product.respond_to?(:image_url=)
    product.update_column(:image_url, url)
  elsif product.respond_to?(:image=) && Product.column_names.include?('image')
    product.update_column(:image, url)
  else
    puts "Product ID #{id}: has no image_url or image string column; nothing updated."
    next
  end

  puts "Product ID #{id}: image updated."
  puts "  Old: #{old}" if old
  puts "  New: #{url}"
end

puts "Done. Refresh /cart to see product images."