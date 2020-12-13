class AllowlistedJwt < ApplicationRecord
  # Associations
  belongs_to :user
  
  # Associations validations
  validates :user, presence: true
  
  # Field validations
  validates :exp, presence: true
  validates :jti, presence: true, uniqueness: true
end
