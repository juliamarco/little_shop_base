require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    # as user
    it { should have_many :orders }
    it { should have_many(:order_items).through(:orders)}
    # as merchant
    it { should have_many :items }
    it { should have_many :coupons }
  end

  describe 'class methods' do
    it ".active_merchants" do
      active_merchants = create_list(:merchant, 3)
      inactive_merchant = create(:inactive_merchant)

      expect(User.active_merchants).to eq(active_merchants)
    end

    describe "statistics" do
      before :each do
        u1 = create(:user, state: "CO", city: "Fairfield")
        u2 = create(:user, state: "OK", city: "OKC")
        u3 = create(:user, state: "IA", city: "Fairfield")
        u4 = create(:user, state: "IA", city: "Des Moines")
        u5 = create(:user, state: "IA", city: "Des Moines")
        u6 = create(:user, state: "IA", city: "Des Moines")
        @m1, @m2, @m3, @m4, @m5, @m6, @m7 = create_list(:merchant, 7)
        i1 = create(:item, merchant_id: @m1.id)
        i2 = create(:item, merchant_id: @m2.id)
        i3 = create(:item, merchant_id: @m3.id)
        i4 = create(:item, merchant_id: @m4.id)
        i5 = create(:item, merchant_id: @m5.id)
        i6 = create(:item, merchant_id: @m6.id)
        i7 = create(:item, merchant_id: @m7.id)
        o1 = create(:completed_order, user: u1)
        o2 = create(:completed_order, user: u2)
        o3 = create(:completed_order, user: u3)
        o4 = create(:completed_order, user: u1)
        o5 = create(:cancelled_order, user: u5)
        o6 = create(:completed_order, user: u6)
        o7 = create(:completed_order, user: u6)
        oi1 = create(:fulfilled_order_item, item: i1, order: o1, created_at: 1.days.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: o2, created_at: 7.days.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: o3, created_at: 6.days.ago)
        oi4 = create(:order_item, item: i4, order: o4, created_at: 4.days.ago)
        oi5 = create(:order_item, item: i5, order: o5, created_at: 5.days.ago)
        oi6 = create(:fulfilled_order_item, item: i6, order: o6, created_at: 3.days.ago)
        oi7 = create(:fulfilled_order_item, item: i7, order: o7, created_at: 2.days.ago)
      end
      it ".merchants_sorted_by_revenue" do
        expect(User.merchants_sorted_by_revenue).to eq([@m7, @m6, @m3, @m2, @m1])
      end

      it ".top_merchants_by_revenue()" do
        expect(User.top_merchants_by_revenue(3)).to eq([@m7, @m6, @m3])
      end

      it ".merchants_sorted_by_fulfillment_time" do
        expect(User.merchants_sorted_by_fulfillment_time(10)).to eq([@m1, @m7, @m6, @m3, @m2])
      end

      it ".top_merchants_by_fulfillment_time" do
        expect(User.top_merchants_by_fulfillment_time(3)).to eq([@m1, @m7, @m6])
      end

      it ".bottom_merchants_by_fulfillment_time" do
        expect(User.bottom_merchants_by_fulfillment_time(3)).to eq([@m2, @m3, @m6])
      end

      it ".top_user_states_by_order_count" do
        expect(User.top_user_states_by_order_count(3)[0].state).to eq("IA")
        expect(User.top_user_states_by_order_count(3)[0].order_count).to eq(3)
        expect(User.top_user_states_by_order_count(3)[1].state).to eq("CO")
        expect(User.top_user_states_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_states_by_order_count(3)[2].state).to eq("OK")
        expect(User.top_user_states_by_order_count(3)[2].order_count).to eq(1)
      end

      it ".top_user_cities_by_order_count" do
        expect(User.top_user_cities_by_order_count(3)[0].state).to eq("CO")
        expect(User.top_user_cities_by_order_count(3)[0].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[0].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[1].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[1].city).to eq("Des Moines")
        expect(User.top_user_cities_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[2].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[2].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[2].order_count).to eq(1)
      end

      it '.with_completed_orders' do
        merchants_with_completed_orders = [@m1, @m2, @m3, @m6, @m7]
        expect(User.with_completed_orders).to eq(merchants_with_completed_orders)
      end

      it '.total_sales' do
        total_sales = { "Merchant Name 1" => 3.0,
                       "Merchant Name 2" => 4.5,
                       "Merchant Name 3" => 6.0,
                       "Merchant Name 6" => 10.5,
                       "Merchant Name 7" => 12.0 }
        expect(User.total_sales).to eq(total_sales)
      end
    end
  end

  describe 'instance methods' do
    before :each do
      @u1 = create(:user, state: "CO", city: "Fairfield")
      @u2 = create(:user, state: "OK", city: "OKC")
      @u3 = create(:user, state: "IA", city: "Fairfield")
      u4 = create(:user, state: "IA", city: "Des Moines")
      u5 = create(:user, state: "IA", city: "Des Moines")
      u6 = create(:user, state: "IA", city: "Des Moines")
      @m1 = create(:merchant)
      @m2 = create(:merchant)
      @i1 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i2 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i3 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i4 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i5 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i6 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i7 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i9 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i8 = create(:item, merchant_id: @m2.id, inventory: 20)
      o1 = create(:completed_order, user: @u1)
      o2 = create(:completed_order, user: @u2)
      o3 = create(:completed_order, user: @u3)
      o4 = create(:completed_order, user: @u1)
      o5 = create(:cancelled_order, user: u5)
      o6 = create(:completed_order, user: u6)
      @oi1 = create(:order_item, item: @i1, order: o1, quantity: 2, created_at: 1.days.ago)
      @oi2 = create(:order_item, item: @i2, order: o2, quantity: 8, created_at: 7.days.ago)
      @oi3 = create(:order_item, item: @i2, order: o3, quantity: 6, created_at: 7.days.ago)
      @oi4 = create(:order_item, item: @i3, order: o3, quantity: 4, created_at: 6.days.ago)
      @oi5 = create(:order_item, item: @i4, order: o4, quantity: 3, created_at: 4.days.ago)
      @oi6 = create(:order_item, item: @i5, order: o5, quantity: 1, created_at: 5.days.ago)
      @oi7 = create(:order_item, item: @i6, order: o6, quantity: 2, created_at: 3.days.ago)
      @oi1.fulfill
      @oi2.fulfill
      @oi3.fulfill
      @oi4.fulfill
      @oi5.fulfill
      @oi6.fulfill
      @oi7.fulfill
    end

    it '.top_items_sold_by_quantity' do
      expect(@m1.top_items_sold_by_quantity(5)[0].name).to eq(@i2.name)
      expect(@m1.top_items_sold_by_quantity(5)[0].quantity).to eq(14)
      expect(@m1.top_items_sold_by_quantity(5)[1].name).to eq(@i3.name)
      expect(@m1.top_items_sold_by_quantity(5)[1].quantity).to eq(4)
      expect(@m1.top_items_sold_by_quantity(5)[2].name).to eq(@i4.name)
      expect(@m1.top_items_sold_by_quantity(5)[2].quantity).to eq(3)
      expect(@m1.top_items_sold_by_quantity(5)[3].name).to eq(@i1.name)
      expect(@m1.top_items_sold_by_quantity(5)[3].quantity).to eq(2)
      expect(@m1.top_items_sold_by_quantity(5)[4].name).to eq(@i6.name)
      expect(@m1.top_items_sold_by_quantity(5)[4].quantity).to eq(2)
    end

    it '.total_items_sold' do
      expect(@m1.total_items_sold).to eq(26)
    end

    it '.total_inventory_remaining' do
      expect(@m1.total_inventory_remaining).to eq(134)
    end

    it '.percent_of_items_sold' do
      expect(@m1.percent_of_items_sold).to eq(16.25)
      merchant_with_no_items_sold = create(:merchant)
      expect(merchant_with_no_items_sold.percent_of_items_sold).to eq(0)
    end

    it '.top_states_by_items_shipped' do
      expect(@m1.top_states_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_states_by_items_shipped(3)[0].quantity).to eq(13)
      expect(@m1.top_states_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_states_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_states_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_states_by_items_shipped(3)[2].quantity).to eq(5)
    end

    it '.top_cities_by_items_shipped' do
      expect(@m1.top_cities_by_items_shipped(3)[0].city).to eq("Fairfield")
      expect(@m1.top_cities_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_cities_by_items_shipped(3)[0].quantity).to eq(10)
      expect(@m1.top_cities_by_items_shipped(3)[1].city).to eq("OKC")
      expect(@m1.top_cities_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_cities_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_cities_by_items_shipped(3)[2].city).to eq("Fairfield")
      expect(@m1.top_cities_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_cities_by_items_shipped(3)[2].quantity).to eq(5)
    end

    it '.top_user_by_order_count' do
      expect(@m1.top_user_by_order_count.name).to eq(@u1.name)
      expect(@m1.top_user_by_order_count.count).to eq(2)
    end

    it '.top_user_by_item_count' do
      expect(@m1.top_user_by_item_count.name).to eq(@u3.name)
      expect(@m1.top_user_by_item_count.quantity).to eq(10)
    end

    it '.top_users_by_money_spent' do
      expect(@m1.top_users_by_money_spent(3)[0].name).to eq(@u3.name)
      expect(@m1.top_users_by_money_spent(3)[0].total).to eq(66.0)
      expect(@m1.top_users_by_money_spent(3)[1].name).to eq(@u2.name)
      expect(@m1.top_users_by_money_spent(3)[1].total).to eq(36.0)
      expect(@m1.top_users_by_money_spent(3)[2].name).to eq(@u1.name)
      expect(@m1.top_users_by_money_spent(3)[2].total).to eq(33.0)
    end

    it '.too_many_coupons?' do
      merchant = create(:merchant)

      coupon_1 = merchant.coupons.create!(code: "123", dollar: 9.0, percentage: true)
      coupon_2 = merchant.coupons.create!(code: "234", dollar: 9.0, percentage: true)
      coupon_3 = merchant.coupons.create!(code: "345", dollar: 9.0, percentage: true)
      coupon_4 = merchant.coupons.create!(code: "456", dollar: 9.0, percentage: true)
      expect(merchant.too_many_coupons?).to eq(false)

      coupon_5 = merchant.coupons.create!(code: "567", dollar: 9.0, percentage: true)
      expect(merchant.too_many_coupons?).to eq(true)
    end

    it '.used_coupon?' do
      merchant = create(:merchant)
      coupon = merchant.coupons.create!(code: "123", dollar: 9.0, percentage: true)

      user_1 = create(:user, state: "CO", city: "Fairfield")
      user_2 = create(:user, state: "CO", city: "Denver")
      order_1 = create(:completed_order, user: user_1, coupon: coupon)
      order_2 = create(:completed_order, user: user_2)

      expect(user_1.used_coupon?(coupon)).to eq(true)
      expect(user_2.used_coupon?(coupon)).to eq(false)
    end

    it '.total_revenue_items' do
      merchant_items_shipped = [@i1, @i2, @i2, @i3, @i4, @i6]
      expect([@m1.total_revenue_items]).to include(merchant_items_shipped.flatten)
    end

    it '.top_states_by_items_shipped_chart' do
      top_states = {"IA"=>13, "OK"=>8, "CO"=>5}

      expect(@m1.top_states_by_items_shipped_chart(3)).to eq(top_states)
    end

    it '.top_items_sold_by_quantity_chart' do
      top_items = {"Item Name 2"=>14, "Item Name 3"=>4, "Item Name 4"=>3}

      expect(@m1.top_items_sold_by_quantity_chart(3)).to eq(top_items)
    end

    it '.top_cities_by_items_shipped_chart' do
      top_cities = {"Fairfield"=>5, "OKC"=>8}

      expect(@m1.top_cities_by_items_shipped_chart(3)).to eq(top_cities)
    end

    it '.percent_of_items_sold_chart' do
      total_sold = {"Total Inventory"=>160, "Items Sold"=>26}

      expect(@m1.percent_of_items_sold_chart).to eq(total_sold)

      merchant_with_no_items_sold = create(:merchant)
      no_sold = chart = {"Total Inventory" => 0, "Items Sold" => 0}
      expect(merchant_with_no_items_sold.percent_of_items_sold_chart).to eq(no_sold)

    end

  end
end
