FactoryBot.define do
  factory :todo do
    association :owner, factory: :user
    title { Faker::Lorem.sentence }
  end
end
