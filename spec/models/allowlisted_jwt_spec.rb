require 'rails_helper'

RSpec.describe AllowlistedJwt, type: :model do
  it 'should have a valid factory' do
    expect(FactoryBot.build(:allowlisted_jwt)).to be_valid
  end
  
  context 'associations' do
    it { should belong_to(:user) }
  end
  
  context 'validations' do
    subject { FactoryBot.build(:allowlisted_jwt) }
    
    context 'associations' do
      it { should validate_presence_of(:user) }
    end
    
    context 'fields' do
      it { should validate_presence_of(:exp) }
      it { should validate_presence_of(:jti) }
      it { should validate_uniqueness_of(:jti) }
    end
  end
end
