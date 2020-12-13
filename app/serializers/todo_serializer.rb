class TodoSerializer < ActiveModel::Serializer
  attribute :completed
  attribute :id
  attribute :owner_id
  attribute :title
end
