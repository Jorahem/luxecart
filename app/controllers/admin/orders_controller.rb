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
      if @order.update(order_params)
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
      params.require(:order).permit(:status)
    end
  end
end