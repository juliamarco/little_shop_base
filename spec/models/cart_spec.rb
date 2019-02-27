require 'rails_helper'

RSpec.describe Cart do
  it '.total_count' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })
    expect(cart.total_item_count).to eq(5)
  end

  it '.items' do
    item_1, item_2 = create_list(:item, 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)

    expect(cart.items).to eq([item_1, item_2])
  end

  it '.count_of' do
    cart = Cart.new({})
    expect(cart.count_of(5)).to eq(0)

    cart = Cart.new({
      '2' => 3
    })
    expect(cart.count_of(2)).to eq(3)
  end

  it '.add_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.add_item(1)
    cart.add_item(2)
    cart.add_item(3)

    expect(cart.contents).to eq({
      '1' => 3,
      '2' => 4,
      '3' => 1
      })
  end

  it '.remove_all_of_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.remove_all_of_item(1)

    expect(cart.contents).to eq({
      '2' => 3
    })
  end

  it '.subtract_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.subtract_item(1)
    cart.subtract_item(1)
    cart.subtract_item(2)

    expect(cart.contents).to eq({
      '2' => 2
      })
  end

  it '.subtotal' do
    item_1 = create(:item)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)

    expect(cart.subtotal(item_1.id)).to eq(item_1.price * cart.total_item_count)
  end

  it '.subtotal_discounted' do
    merchant = create(:merchant)
    merchant_2 = create(:merchant)
    coupon = merchant.coupons.create!(code: "123", dollar: 2.0, percentage: false)
    coupon_2 = merchant.coupons.create!(code: "234", dollar: 25.0, percentage: true)
    item_1 = create(:item, user: merchant)
    item_2 = create(:item, user: merchant_2)

    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)

    expect(cart.subtotal_discounted(coupon, item_1.id)).to eq(10)
    expect(cart.subtotal_discounted(coupon_2, item_1.id)).to eq(9)
    expect(cart.subtotal_discounted(coupon_2, item_2.id)).to eq(4.5)
  end

  it '.grand_total' do

    item_1, item_2 = create_list(:item, 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)
    cart.add_item(item_2.id)
    cart.add_item(item_2.id)

    expect(cart.grand_total).to eq(cart.subtotal(item_1.id) + cart.subtotal(item_2.id))

    cart = Cart.new({})
    merchant = create(:merchant)
    coupon = merchant.coupons.create!(code: "123", dollar: 2.0, percentage: false)
    item_3 = create(:item, user: merchant)
    cart.add_item(item_3.id)

    expect(cart.grand_total(coupon)).to eq(4.0)
  end
end
