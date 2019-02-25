FactoryBot.define do

  factory :coupon do
    association :user, factory: :merchant
    sequence(:code) { |n| "ABC#{n}" }
    sequence(:percentage) { false }
    sequence(:dollar) { |n| ("#{n}".to_i+1)*1.5 }
    active { true }
  end

  factory :percent_coupon, parent: :coupon do
    association :user, factory: :merchant
    sequence(:code) { |n| "DEF#{n}" }
    sequence(:percentage) { true }
    sequence(:dollar) { |n| n * 25 }
    active { true }
  end

  factory :inactive_coupon, parent: :coupon do
    association :user, factory: :merchant
    sequence(:code) { |n| "Inactive Code #{n}" }
    active { false }
  end
end
