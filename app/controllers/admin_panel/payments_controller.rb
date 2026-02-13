module AdminPanel
  class PaymentsController < AdminPanel::BaseController
    def index
      # No Payment model found in repo; use Order payments instead.
      @orders =
        Order
          .includes(:user)
          .order(created_at: :desc)
    end

    def show
      @order = Order.includes(:user, :order_items).find(params[:id])
    end
  end
end