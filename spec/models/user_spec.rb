require 'rails_helper'

RSpec.describe User, type: :model do
  it 'should have a valid factory' do
    expect(FactoryBot.build(:user)).to be_valid
  end
  
  context 'validations' do
    subject { FactoryBot.build(:user) }
    
    context 'fields' do
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).case_insensitive }
      it { should allow_value('correct_format@gmail.com').for(:email) }
      it { should_not allow_value('incorrect_format').for(:email) }
      it { should validate_presence_of(:name) }
      it { should validate_length_of(:name).is_at_least(3).is_at_most(50) }
      it { should validate_presence_of(:password) }
      it { should validate_confirmation_of(:password) }
      it { should validate_length_of(:password).is_at_least(6).is_at_most(128) }
    end
  end
  
  context 'normalizations' do
    it 'should strip the :name' do
      user = FactoryBot.build(:user, name: ' John ')
      expect(user.name).to eq('John')
    end
  end
end
