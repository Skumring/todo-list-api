class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist
  
  devise :database_authenticatable, :registerable, :recoverable, :validatable,
          :jwt_authenticatable, jwt_revocation_strategy: self
         
  # Associations
  has_many :allowlisted_jwts, dependent: :destroy
  
  # Field validations
  validates :name, presence: true, length: { in: 3..50 }
  
  # Normalizations
  def name=(value)
    super(value&.strip)
  end
end
