class Cart
  attr_reader :contents

  def initialize(initial_contents)
    @contents = initial_contents || Hash.new(0)
  end

  def items
    @contents.keys.map do |item_id|
      Item.includes(:user).find(item_id)
    end
  end

  def total_item_count
    @contents.values.sum
  end

  def count_of(item_id)
    @contents[item_id.to_s].to_i
  end

  def add_item(item_id)
    @contents[item_id.to_s] ||= 0
    @contents[item_id.to_s] += 1
  end

  def subtract_item(item_id, count=1)
    @contents[item_id.to_s] -= count
    @contents.delete(item_id.to_s) if @contents[item_id.to_s] == 0
  end

  def remove_all_of_item(item_id)
    subtract_item(item_id, count_of(item_id))
  end

  def subtotal(item_id)
    item = Item.find(item_id)
    item.price * count_of(item_id)
  end

  def subtotal_discounted(coupon, item_id)
    original_subtotal = subtotal(item_id)
    if coupon.percentage?
      disc = (original_subtotal * coupon.dollar) / 100
      original_subtotal - disc
    else
      original_subtotal - coupon.dollar
    end
  end

  def grand_total(coupon = nil)
    if coupon.nil?
      @contents.keys.map do |item_id|
        subtotal(item_id)
      end.sum
    else
      @contents.keys.map do |item_id|
        subtotal_discounted(coupon, item_id)
      end.sum
    end
  end
end
