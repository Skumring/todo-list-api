FactoryBot.define do
  factory :allowlisted_jwt do
    association :user, factory: :user
    
    aud { SecureRandom.hex(4) }
    exp { 1.day.from_now }
    jti { SecureRandom.hex(4) }
  end
end
