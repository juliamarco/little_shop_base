class Merchants::CouponsController < ApplicationController
  before_action :merchant_or_admin

  def index
    @coupons = Coupon.where(user: current_user)
  end

  def new
    @coupon = Coupon.new
    @form_path = [:dashboard, @coupon]
  end

  def create
    coupon_params[:active] = true
    @merchant = current_user
    if @merchant.too_many_coupons?
      flash[:error] = "You can't have more than 5 coupons!"
      redirect_to dashboard_coupons_path
    else
      @coupon = @merchant.coupons.create(coupon_params)
      if @coupon.save
        flash[:success] = "Coupon '#{@coupon.code}' has been added!"
        redirect_to dashboard_coupons_path
      else
        render :new
      end
    end
  end

  private

  def coupon_params
    strong = params.require(:coupon).permit(:code, :percentage, :active, :dollar)
    if strong[:percentage] == "Dollars"
      strong[:percentage] = false
    else
      strong[:percentage] = true
    end
    strong
  end
end
