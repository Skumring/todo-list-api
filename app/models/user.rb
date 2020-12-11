class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable
         
  # Field validations
  validates :name, presence: true, length: { in: 3..50 }
  
  # Normalizations
  def name=(value)
    super(value&.strip)
  end
end
