class CouponsController < ApplicationController
  before_action :require_user

  def create
    @coupon = Coupon.find_by(code: params[:coupon])
    if @coupon && @coupon.active
      unless current_user && current_user.used_coupon?(@coupon)
        session[:coupon] = @coupon.id
        flash[:success] = "Coupon '#{@coupon.code}' successfully applied"
      else
        flash[:error] = "You have already applied coupon '#{@coupon.code}'"
      end
    else
      flash[:error] = "Invalid coupon. Try again"
    end
    redirect_to cart_path
  end

end
