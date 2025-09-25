FactoryBot.define do
  factory :cart do
    trait :with_products do
      transient do
        products_count { 1 }
      end

      after(:create) do |cart, evaluator|
        create_list(:line_item, evaluator.products_count, cart: cart)
        cart.reload
      end
    end
  end
end