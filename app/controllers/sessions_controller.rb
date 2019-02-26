class SessionsController < ApplicationController

  def new
    if current_user
      redirect_by_role
    end
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user && @user.authenticate(params[:password])
      if @user.active?
        session[:user_id] = @user.id
        if session[:coupon]
          coupon = Coupon.find(session[:coupon])
          if current_user.used_coupon?(coupon)
            session.delete
          end
        end
        redirect_by_role
      else
        flash[:error] = 'Your account is inactive, contact an admin for help'
        flash[:error] = 'Your account is inactive, contact an admin for help'
        render :new
      end
    else
      flash[:error] = 'Your credentials are bad and you should feel bad'
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def redirect_by_role
    if current_reguser?
      redirect_to profile_path
    elsif current_merchant?
      redirect_to dashboard_path
    elsif current_admin?
      redirect_to admin_dashboard_index_path
    end
  end
end
