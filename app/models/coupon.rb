class Coupon < ApplicationRecord
  belongs_to :user, foreign_key: 'merchant_id'

  has_many :orders

  validates_presence_of [:code, :percentage, :dollar]
  validates_uniqueness_of :code
end
