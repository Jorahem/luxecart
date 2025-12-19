module Admin
  class OrdersController < AdminController
    before_action :set_order, only: [:show, :update_status]

    def index
      @orders = Order.includes(:user).order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
      @order_items = @order.order_items.includes(:product)
    end

    def update_status
      if @order.update(status: params[:status])
        redirect_to admin_order_path(@order), notice: 'Order status updated successfully.'
      else
        redirect_to admin_order_path(@order), alert: 'Failed to update order status.'
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
