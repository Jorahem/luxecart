module Admin
  class OrdersController < AdminController
    before_action :set_order, only: [:show, :update_status, :mark_as_shipped, :mark_as_delivered]

    def index
      @orders = Order.order(created_at: :desc).limit(50)
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

    def mark_as_shipped
      if @order.update(status: :shipped, shipped_at: Time.current, tracking_number: params[:tracking_number])
        redirect_to admin_order_path(@order), notice: 'Order marked as shipped.'
      else
        redirect_to admin_order_path(@order), alert: 'Failed to mark order as shipped.'
      end
    end

    def mark_as_delivered
      if @order.update(status: :delivered, delivered_at: Time.current)
        redirect_to admin_order_path(@order), notice: 'Order marked as delivered.'
      else
        redirect_to admin_order_path(@order), alert: 'Failed to mark order as delivered.'
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
