class Coupon < ApplicationRecord
  belongs_to :user, foreign_key: 'merchant_id'

  has_many :orders

  validates_presence_of [:code, :dollar]
  validates_uniqueness_of :code

  def never_used?
    orders.empty?
  end

end
