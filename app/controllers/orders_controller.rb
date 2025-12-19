class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :cancel]

  def index
    @orders = current_user.orders.recent.page(params[:page]).per(10)
  end

  def show
    @order_items = @order.order_items.includes(:product)
  end

  def cancel
    if @order.pending? || @order.processing?
      @order.update(status: :cancelled, cancelled_at: Time.current)
      @order.order_items.each do |item|
        item.product.increment!(:stock_quantity, item.quantity)
      end
      redirect_to order_path(@order), notice: 'Order cancelled successfully.'
    else
      redirect_to order_path(@order), alert: 'Order cannot be cancelled.'
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end
end