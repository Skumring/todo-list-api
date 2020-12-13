class Todo < ApplicationRecord
  # Associations
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  
  # Associations validations
  validates :owner, presence: true
  
  # Field validations
  validates :completed, inclusion: { in: [true, false] }
  validates :title, presence: true
end
