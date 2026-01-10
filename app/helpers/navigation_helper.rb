module NavigationHelper
  # Returns 'active' if current page matches the path (used to highlight menu items)
  def nav_active_class(path)
    current_page?(path) ? 'active' : ''
  end

  # Returns integer count of items in session cart
  def cart_item_count
    (session[:cart] || {}).values.map(&:to_i).sum
  end
end