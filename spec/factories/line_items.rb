FactoryBot.define do
  factory :line_item do
    association :cart
    association :product
    quantity { 1 }
  end
end