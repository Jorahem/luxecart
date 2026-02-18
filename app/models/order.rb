class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  enum payment_status: { pending: 0, paid: 1, failed: 2 }, _prefix: true

  # Status flow for tracking:
  # NOTE: Your controllers already use `status: :processing` (CheckoutController),
  # so we must include it to avoid breaking updates.
  # Keep `paid` too so any existing code that references it won't crash.
  enum status: {
    pending: 0,     # order created
    paid: 1,        # kept for backward-compatibility
    processing: 2,  # preparing the order
    shipped: 3,     # handed to courier
    delivered: 4,   # delivered to address
    received: 5,    # customer confirmed received
    cancelled: 6    # optional
  }

  # -----------------------------
  # Tracking History (NEW)
  # -----------------------------
  has_many :order_tracking_events, dependent: :destroy

  # Log first tracking event on order create
  after_create :log_initial_tracking_event

  # Log new tracking event whenever status changes
  after_update :log_tracking_event_if_status_changed

  # Create a tracking event safely
  def add_tracking_event!(status:, message: nil, location: nil, happened_at: Time.current)
    order_tracking_events.create!(
      status: status.to_s,
      message: message,
      location: location,
      happened_at: happened_at
    )
  end

  # The DB stores the customer's name as `shipping_full_name` (snapshot fields).
  # Validate the shipping snapshot fields which are present in the schema.
  validates :shipping_full_name, :shipping_street, :shipping_city, :shipping_postal_code, presence: true

  # Ensure we have an order_number for DB NOT NULL constraint.
  before_create :generate_order_number

  # Provide a convenience `full_name` accessor used in views/calls that expect it.
  # Prefer the snapshot shipping_full_name, otherwise fall back to the user's full_name if available.
  def full_name
    shipping_full_name.presence || user&.full_name
  end

  # --- Tracking helpers (safe additions, won't affect old code) ---

  # Used for a "timeline" UI: pending -> paid -> processing -> shipped -> delivered -> received
  def tracking_steps
    %w[pending paid processing shipped delivered received]
  end

  def status_step_index
    tracking_steps.index(status.to_s) || 0
  end

  def can_mark_received?
    delivered? && !received?
  end

  private

  # Create first event for newly created orders
  def log_initial_tracking_event
    add_tracking_event!(
      status: status.to_s,
      message: "Order placed",
      happened_at: created_at || Time.current
    )
  rescue => e
    Rails.logger.error "[Order#log_initial_tracking_event] #{e.class}: #{e.message}"
    true
  end

  # Create an event when status changes
  def log_tracking_event_if_status_changed
    return unless saved_change_to_status?

    new_status = status.to_s

    msg =
      case new_status
      when "pending" then "Order placed"
      when "paid" then "Payment confirmed"
      when "processing" then "Order is being processed"
      when "shipped" then "Order shipped"
      when "delivered" then "Order delivered"
      when "received" then "Customer marked order as received"
      when "cancelled" then "Order cancelled"
      else "Status updated to #{new_status}"
      end

    add_tracking_event!(
      status: new_status,
      message: msg,
      happened_at: Time.current
    )
  rescue => e
    Rails.logger.error "[Order#log_tracking_event_if_status_changed] #{e.class}: #{e.message}"
    true
  end

  after_initialize do
  self.admin_seen = false if self.admin_seen.nil?
end
  # Generates a reasonably human-friendly and unique order number.
  # Format example: ORD20260117-4f3c9a8b
  def generate_order_number
    return if order_number.present?

    # Try until unique (should succeed quickly)
    loop do
      candidate = "ORD#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(4)}"
      unless self.class.exists?(order_number: candidate)
        self.order_number = candidate
        break
      end
    end
  end
end