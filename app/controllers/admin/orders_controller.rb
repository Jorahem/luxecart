require "csv"

module Admin
  class OrdersController < BaseController
    def index
      @orders = Order.order(created_at: :desc)
      @orders = @orders.where(status: params[:status]) if params[:status].present?
    end

    def show
      @order = Order.find(params[:id])
    end

    def update
      @order = Order.find(params[:id])

      # Start from permitted attributes
      next_attrs = order_params.to_h

      # If admin changes status, automatically set timestamps the first time
      # the order reaches shipped/delivered (safe + doesn't affect old behavior).
      if next_attrs["status"].present?
        new_status = next_attrs["status"].to_s

        if new_status == "shipped" && @order.respond_to?(:shipped_at) && @order.shipped_at.blank?
          next_attrs["shipped_at"] = Time.current
        end

        if new_status == "delivered" && @order.respond_to?(:delivered_at) && @order.delivered_at.blank?
          next_attrs["delivered_at"] = Time.current
        end
      end

      if @order.update(next_attrs)
        redirect_to admin_order_path(@order), notice: "Order updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def export
      @orders = Order.all
      csv = CSV.generate(headers: true) do |csv|
        csv << %w[ID Status UserId TotalPrice CreatedAt]
        @orders.each do |o|
          csv << [o.id, o.status, o.user_id, o.total_price, o.created_at]
        end
      end
      send_data csv, filename: "orders-#{Date.today}.csv"
    end

    private

    def order_params
      # Add tracking fields safely (they already exist in your schema)
      params.require(:order).permit(
        :status,
        :tracking_number,
        :shipped_at,
        :delivered_at
      )
    end
  end
end