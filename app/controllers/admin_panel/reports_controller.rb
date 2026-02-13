module AdminPanel
  class ReportsController < AdminPanel::BaseController
    def index
      range = selected_range

      @total_users = User.count
      @new_users = User.where(created_at: range).count

      @orders_in_range = Order.where(created_at: range)
      @total_orders = Order.count

      @paid_orders =
        if Order.respond_to?(:payment_status_paid)
          @orders_in_range.payment_status_paid.count
        elsif Order.column_names.include?("payment_status")
          @orders_in_range.where(payment_status: "paid").count
        else
          0
        end

      @failed_orders =
        if Order.respond_to?(:payment_status_failed)
          @orders_in_range.payment_status_failed.count
        elsif Order.column_names.include?("payment_status")
          @orders_in_range.where(payment_status: "failed").count
        else
          0
        end

      @revenue =
        if Order.column_names.include?("total_price")
          @orders_in_range.where.not(total_price: nil).sum(:total_price)
        else
          0
        end

      # Average order value (AOV)
      @aov =
        if Order.column_names.include?("total_price")
          paid_scope =
            if Order.respond_to?(:payment_status_paid)
              @orders_in_range.payment_status_paid
            elsif Order.column_names.include?("payment_status")
              @orders_in_range.where(payment_status: "paid")
            else
              @orders_in_range
            end

          count = paid_scope.count
          count.positive? ? (paid_scope.sum(:total_price).to_f / count) : 0
        else
          0
        end

      # Orders by status
      @orders_by_status =
        if Order.column_names.include?("status")
          @orders_in_range.group(:status).count
        else
          {}
        end

      # Payment method split (if payment_method exists)
      @payment_methods =
        if Order.column_names.include?("payment_method")
          @orders_in_range.group(:payment_method).count
        else
          {}
        end

      # Top products by quantity sold
      @top_products =
        if defined?(OrderItem)
          OrderItem
            .joins(:product)
            .joins(:order)
            .where(orders: { created_at: range })
            .group("products.id", "products.name")
            .select("products.id, products.name, SUM(order_items.quantity) AS qty_sold")
            .order("qty_sold DESC")
            .limit(10)
        else
          []
        end

      # Top customers (by revenue) - only if orders have user_id and total_price
      @top_customers =
        if Order.column_names.include?("user_id") && Order.column_names.include?("total_price")
          scope =
            if Order.respond_to?(:payment_status_paid)
              @orders_in_range.payment_status_paid
            elsif Order.column_names.include?("payment_status")
              @orders_in_range.where(payment_status: "paid")
            else
              @orders_in_range
            end

          scope
            .where.not(user_id: nil)
            .joins(:user)
            .group("users.id", "users.first_name", "users.last_name", "users.email")
            .select("users.id, users.first_name, users.last_name, users.email, SUM(orders.total_price) AS spend")
            .order("spend DESC")
            .limit(10)
        else
          []
        end

      @recent_orders = Order.order(created_at: :desc).limit(10)

      # Executive insights (simple, but looks premium)
      @insights = build_insights
    end

    private

    def selected_range
      case params[:range].to_s
      when "7d" then 7.days.ago.beginning_of_day..Time.current
      when "30d" then 30.days.ago.beginning_of_day..Time.current
      when "90d" then 90.days.ago.beginning_of_day..Time.current
      else
        30.days.ago.beginning_of_day..Time.current
      end
    end

    def build_insights
      total_orders = @orders_in_range.count
      paid = @paid_orders.to_i
      failed = @failed_orders.to_i

      approval_rate =
        if total_orders.positive?
          ((paid.to_f / total_orders) * 100).round
        else
          0
        end

      [
        { title: "Payment success rate", value: "#{approval_rate}%", note: "Paid orders vs total orders in range" },
        { title: "Revenue", value: (@revenue.respond_to?(:to_f) ? sprintf("$%.2f", @revenue.to_f) : @revenue.to_s), note: "Total in selected range" },
        { title: "New users", value: @new_users.to_s, note: "Signups in selected range" },
        { title: "Failed payments", value: failed.to_s, note: "Orders marked failed in range" }
      ]
    end
  end
end