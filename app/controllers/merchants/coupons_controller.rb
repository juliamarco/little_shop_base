class Merchants::CouponsController < ApplicationController
  before_action :merchant_or_admin

  def index
    @coupons = Coupon.where(user: current_user)
  end

end
