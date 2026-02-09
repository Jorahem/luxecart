class FixOrderStatusesForTracking < ActiveRecord::Migration[7.1]
  def up
    # Old mapping used status=1 as "paid".
    # New mapping uses status=1 as "processing".
    # This is effectively a rename; keep numeric value the same.
    # No data change needed unless you stored some other meaning.
    #
    # If you had any custom statuses, adjust here.
  end

  def down
    # No-op: keeping the same integer value (1) means rollback is unnecessary.
  end
end