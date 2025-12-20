module Admin
  class OrdersController < AdminController
    before_action :set_order, only: [:show, :update_status]

    def index
      @orders = Order.includes(:user).order(created_at: :desc).page(params[:page]).per(20)
      @orders = @orders.where(status: params[:status]) if params[:status].present?
    end

    def show
      @order_items = @order.order_items.includes(:product)
    end

    def update_status
      if @order.update(status: params[:status])
        case params[:status]
        when 'shipped'
          @order.update(shipped_at: Time.current)
          # OrderMailer.shipped(@order).deliver_later
        when 'delivered'
          @order.update(delivered_at: Time.current)
          # OrderMailer.delivered(@order).deliver_later
        when 'cancelled'
          @order.update(cancelled_at: Time.current)
          # Restore inventory
          @order.order_items.each do |item|
            item.product.increment!(:stock_quantity, item.quantity)
          end
        end
        
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
