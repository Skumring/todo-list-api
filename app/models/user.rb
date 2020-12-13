class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist
  
  devise :database_authenticatable, :registerable, :validatable,
          :jwt_authenticatable, jwt_revocation_strategy: self
         
  # Associations
  has_many :allowlisted_jwts, dependent: :destroy
  has_many :own_todos, class_name: 'Todo', foreign_key: 'owner_id', dependent: :destroy
  
  # Field validations
  validates :name, presence: true, length: { in: 3..50 }
  
  # Normalizations
  def name=(value)
    super(value&.strip)
  end
end
