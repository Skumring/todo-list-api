require 'rails_helper'

RSpec.describe Todo, type: :model do
  it 'should have a valid factory' do
    expect(FactoryBot.build(:todo)).to be_valid
  end
  
  context 'associations' do
    it { should belong_to(:owner) }
  end
  
  context 'validations' do
    subject { FactoryBot.build(:todo) }
    
    context 'associations' do
      it { should validate_presence_of(:owner) }
    end
    
    context 'fields' do
      it { should validate_presence_of(:title) }
    end
  end
end
