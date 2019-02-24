class AddCouponToOrders < ActiveRecord::Migration[5.1]
  def change
    add_reference(:orders, :coupon, foreign_key: {to_table: :coupons})
  end
end
