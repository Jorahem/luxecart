module AdminPanel
  class RealtimeController < BaseController
    # Keep this lightweight; returns a small JSON payload the dashboard polls.
    def index
      recent_orders = Order.order(created_at: :desc).limit(10).includes(order_items: :product)

      payload = recent_orders.map do |o|
        {
          order_id: o.id,
          order_number: o.try(:order_number) || "##{o.id}",
          total_price: o.try(:total_price).to_f,
          created_at: o.created_at.iso8601,
          items: o.order_items.map do |it|
            p = it.product
            {
              product_id: p&.id,
              name: p&.name || it.try(:name) || "Product",
              qty: it.quantity,
              unit_price: (it.try(:unit_price) || it.try(:price) || 0).to_f,
              image_url: product_image_url(p)
            }
          end
        }
      end

      render json: { recent_purchases: payload, server_time: Time.current.iso8601 }
    end

    private

    def product_image_url(product)
      return nil unless product
      if product.respond_to?(:image_url) && product.image_url.present?
        product.image_url
      elsif product.respond_to?(:image) && product.image.is_a?(String) && product.image.present?
        product.image
      else
        "https://via.placeholder.com/300x300?text=No+Image"
      end
    rescue
      "https://via.placeholder.com/300x300?text=No+Image"
    end
  end
end