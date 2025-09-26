FactoryBot.define do
  factory :cart, aliases: [:shopping_cart] do
    total_price { 0.0 }
    abandoned { false }
    abandoned_at { nil }
    last_interaction_at { Time.current }
    
    trait :with_products do
      transient do
        products_count { 1 }
      end

      after(:create) do |cart, evaluator|
        create_list(:line_item, evaluator.products_count, cart: cart)
        cart.reload
      end
    end
    
    trait :abandoned do
      abandoned { true }
      abandoned_at { Time.current }
      last_interaction_at { 4.hours.ago }
    end
    
    trait :old_abandoned do
      abandoned { true }
      abandoned_at { 8.days.ago }
      last_interaction_at { 10.days.ago }
    end
  end
end