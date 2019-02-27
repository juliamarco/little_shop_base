  require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it { should validate_presence_of :status }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should belong_to :coupon }
    it { should have_many :order_items }
    it { should have_many(:items).through(:order_items) }
  end

  describe 'Class Methods' do
    before :each do
      @o1 = create(:completed_order)
      @o2 = create(:completed_order)
      @o3 = create(:completed_order)
      @o4 = create(:completed_order)
      @o5 = create(:cancelled_order)
      @o6 = create(:completed_order)
      @o7 = create(:completed_order)
      oi1 = create(:fulfilled_order_item, order: @o1)
      oi2 = create(:fulfilled_order_item, order: @o7)
      oi3 = create(:fulfilled_order_item, order: @o2)
      oi4 = create(:order_item, order: @o6)
      oi5 = create(:order_item, order: @o3)
      oi6 = create(:fulfilled_order_item, order: @o5)
      oi7 = create(:fulfilled_order_item, order: @o4)
      @merchant = create(:merchant)
      @i1, @i2 = create_list(:item, 2, user: @merchant)
      @o8, @o9 = create_list(:order, 2)
      create(:order_item, order: @o8, item: @i1, quantity: 1, price: 2)
      create(:order_item, order: @o8, item: @i2, quantity: 2, price: 2)
      create(:order_item, order: @o9, item: @i2, quantity: 4, price: 2)
    end

    it '.sorted_by_items_shipped' do
      expect(Order.sorted_by_items_shipped).to eq([@o4, @o2, @o7, @o1])
    end

    it '.top_orders_by_items_shipped' do
      expect(Order.sorted_by_items_shipped(3)).to eq([@o4, @o2, @o7])
      expect(Order.sorted_by_items_shipped(3)[0].id).to eq(@o4.id)
      expect(Order.sorted_by_items_shipped(3)[0].quantity).to eq(16)
      expect(Order.sorted_by_items_shipped(3)[1].id).to eq(@o2.id)
      expect(Order.sorted_by_items_shipped(3)[1].quantity).to eq(8)
      expect(Order.sorted_by_items_shipped(3)[2].id).to eq(@o7.id)
      expect(Order.sorted_by_items_shipped(3)[2].quantity).to eq(6)
    end

    it '.pending_orders_for_merchant' do
      expect(Order.pending_orders_for_merchant(@merchant.id)).to eq([@o8, @o9])
    end
  end

  describe 'instance methods' do
    before :each do
      user = create(:user)
      @item_1 = create(:item)
      @item_2 = create(:item)
      yesterday = 1.day.ago

      @order = create(:order, user: user, created_at: yesterday)
      @oi_1 = create(:order_item, order: @order, item: @item_1, price: 1, quantity: 1, created_at: yesterday, updated_at: yesterday)
      @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 1, created_at: yesterday, updated_at: 2.hours.ago)

      @merchant = create(:merchant)
      @i1, @i2 = create_list(:item, 2, user: @merchant)
      @o1, @o2 = create_list(:order, 2)
      @o3 = create(:completed_order)
      @o4 = create(:cancelled_order)
      create(:order_item, order: @o1, item: @i1, quantity: 1, price: 2)
      create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
      create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
      create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
      create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)
    end

    it '.total_item_count' do
      expect(@order.total_item_count).to eq(@oi_1.quantity + @oi_2.quantity)
    end

    it '.total_cost' do
      coupon = @merchant.coupons.create!(code: "123", dollar: 2.0, percentage: false)
      coupon_2 = @merchant.coupons.create!(code: "234", dollar: 25.0, percentage: true)

      expect(@order.total_cost).to eq((@oi_1.quantity*@oi_1.price) + (@oi_2.quantity*@oi_2.price))
      expect(@order.total_cost).to eq(3)

      user = create(:user)
      order = create(:order, user: user, discounted_total: 3.0)
      expect(order.total_cost(order.discounted_total)).to eq(0)
    end

    it '.total_quantity_for_merchant' do
      expect(@o1.total_quantity_for_merchant(@merchant.id)).to eq(3)
      expect(@o2.total_quantity_for_merchant(@merchant.id)).to eq(4)
    end

    it '.total_price_for_merchant' do
      expect(@o1.total_price_for_merchant(@merchant.id)).to eq(6.0)
      expect(@o2.total_price_for_merchant(@merchant.id)).to eq(8.0)
    end

    it '.order_items_for_merchant' do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      user = create(:user)
      order = create(:order, user: user)
      item1 = create(:item, user: merchant1)
      item2 = create(:item, user: merchant2)
      item3 = create(:item, user: merchant1)
      oi1 = create(:order_item, order: order, item: item1, quantity: 1, price: 2)
      oi2 = create(:order_item, order: order, item: item2, quantity: 2, price: 3)
      oi3 = create(:order_item, order: order, item: item3, quantity: 3, price: 4)

      expect(order.order_items_for_merchant(merchant1.id)).to eq([oi1, oi3])
    end
  end
end
