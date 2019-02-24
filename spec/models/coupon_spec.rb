require 'rails_helper'

describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of :code }
    it { should validate_uniqueness_of :code }
    it { should validate_presence_of :dollar }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :orders }
  end

  describe 'instance methods' do
    it '.never_used?' do
      merchant = create(:merchant)
      coupon_1 = merchant.coupons.create!(code: "123", dollar: 9.0, percentage: true)
      coupon_2 = merchant.coupons.create!(code: "345", dollar: 9.0, percentage: true)
      user = create(:user, state: "IA", city: "Des Moines")

      order = create(:completed_order, user: user, coupon: coupon_1)
      expect(coupon_2.never_used?).to eq(true)
      expect(coupon_1.never_used?).to eq(false)
    end
  end

end
