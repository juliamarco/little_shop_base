class CartController < ApplicationController
before_action :visitor_or_user
  include ActionView::Helpers::TextHelper

  def show
    @items = @cart.items
    @coupon = session[:coupon] && Coupon.find(session[:coupon])
  end

  def destroy
    session.delete(:cart)
    redirect_to cart_path
  end

  def add
    add_item_to_cart(params[:id])
    redirect_to items_path
  end

  def remove_all_of_item
    remove_item(params[:id])
    redirect_to cart_path
  end

  def add_more_item
    add_item_to_cart(params[:id])
    redirect_to cart_path
  end

  def remove_more_item
    remove_item(params[:id], 1)
    redirect_to cart_path
  end

  private

  def remove_item(item_id, count=nil)
    item = Item.find(params[:id])
    if count.nil?
      @cart.remove_all_of_item(item.id)
      flash[:success] = "You have removed all packages of #{item.name} from your cart"
    else
      @cart.subtract_item(item.id)
      flash[:success] = "You have removed 1 package of #{item.name} from your cart, new quantity is #{@cart.count_of(item.id)}"
    end
    session[:cart] = @cart.contents
  end

  def add_item_to_cart(item_id)
    if item = Item.where(id: item_id).first
      @cart.add_item(item.id)
      flash[:success] = "You have #{pluralize(@cart.count_of(item.id), 'package')} of #{item.name} in your cart"
      session[:cart] = @cart.contents
    else
      flash[:error] = 'Cannot add that item'
    end
  end
end
