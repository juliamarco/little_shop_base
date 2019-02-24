FactoryBot.define do
  factory :order, class: Order do
    user
    # coupon
    status { :pending }
  end
  factory :completed_order, parent: :order do
    user
    # coupon
    status { :completed }
  end
  factory :cancelled_order, parent: :order do
    user
    # coupon
    status { :cancelled }
  end
end
