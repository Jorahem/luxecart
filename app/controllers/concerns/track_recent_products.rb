module TrackRecentProducts
  MAX_RECENT_PRODUCTS = 10

  def track_recent_product(product)
    ids = (cookies.encrypted[:recent_product_ids].presence || "").split(",").map(&:to_i)
    ids.unshift(product.id)
    ids.uniq!
    ids = ids.first(MAX_RECENT_PRODUCTS)
    cookies.encrypted[:recent_product_ids] = {
      value: ids.join(","),
      expires: 30.days.from_now
    }
  end

  def recent_products
    ids = (cookies.encrypted[:recent_product_ids].presence || "").split(",").map(&:to_i)
    return Product.none if ids.empty?
    # Preserve order as much as possible
    products = Product.where(id: ids)
    products.sort_by { |p| ids.index(p.id) || ids.length }
  end
end