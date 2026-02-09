module AdminPanel
  class OrdersController < AdminPanel::BaseController
    before_action :set_order, only: [:show, :edit, :update, :destroy, :update_status, :mark_as_shipped, :mark_as_delivered]

    def index
      @orders = Order.order(created_at: :desc)
      @orders = @orders.where(status: params[:status]) if params[:status].present?
    end

    def show; end
    def new; @order = Order.new; end
    def edit; end

    def create
      @order = Order.new(order_params)
      if @order.save
        redirect_to admin_order_path(@order), notice: "Order created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      attrs = order_params.to_h
      apply_status_timestamps!(attrs)

      if @order.update(attrs)
        redirect_to admin_order_path(@order), notice: "Order updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @order.destroy
      redirect_to admin_orders_path, notice: "Order deleted."
    end

    # PATCH /admin/orders/:id/update_status
    def update_status
      attrs = {}
      attrs[:status] = params[:status] if params[:status].present?
      apply_status_timestamps!(attrs)

      if attrs[:status].blank?
        redirect_to admin_order_path(@order), alert: "Missing status." and return
      end

      if @order.update(attrs)
        redirect_to admin_order_path(@order), notice: "Status updated."
      else
        redirect_to admin_order_path(@order), alert: @order.errors.full_messages.to_sentence
      end
    end

    # PATCH /admin/orders/:id/mark_as_shipped
    def mark_as_shipped
      attrs = { status: :shipped }
      apply_status_timestamps!(attrs)

      if @order.update(attrs)
        redirect_to admin_order_path(@order), notice: "Order marked as shipped."
      else
        redirect_to admin_order_path(@order), alert: @order.errors.full_messages.to_sentence
      end
    end

    # PATCH /admin/orders/:id/mark_as_delivered
    def mark_as_delivered
      attrs = { status: :delivered }
      apply_status_timestamps!(attrs)

      if @order.update(attrs)
        redirect_to admin_order_path(@order), notice: "Order marked as delivered."
      else
        redirect_to admin_order_path(@order), alert: @order.errors.full_messages.to_sentence
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:status, :tracking_number, :shipped_at, :delivered_at, :notes)
    end

    def apply_status_timestamps!(attrs)
      return if attrs[:status].blank?

      new_status = attrs[:status].to_s

      if new_status == "shipped" && @order.respond_to?(:shipped_at) && @order.shipped_at.blank?
        attrs[:shipped_at] ||= Time.current
      end

      if new_status == "delivered" && @order.respond_to?(:delivered_at) && @order.delivered_at.blank?
        attrs[:delivered_at] ||= Time.current
      end
    end
  end
end