class CreateCoupon < ActiveRecord::Migration[5.1]
  def change
    create_table :coupons do |t|
      t.string :code
      t.boolean :percentage, default: false
      t.float :dollar, default: 0.0
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
