require 'rails_helper'

RSpec.describe Api::V1::RegistrationsController, type: :request do
  describe 'routing', type: :routing do
    it { should route(:post, '/api/v1/sign_up').to(action: :create, format: :json) }
  end
  
  describe 'POST #sign_up' do
    let(:user) { FactoryBot.create(:user) }
    let(:user_attr) { FactoryBot.attributes_for(:user) }
    let(:sign_up_url) { '/api/v1/sign_up' }
    
    context 'with valid params' do
      context 'when that is a User with unique credentials' do
        before do
          post sign_up_url, params: { user: user_attr }
        end
        
        it 'should have :created (201) HTTP response status' do
          expect(response).to have_http_status(201)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return Authorization JWT token' do
          expect(response.headers['Authorization']).to be_present
        end
        
        it 'should return correct user attributes' do
          expect_json_keys('user', [:email, :id, :name])
        end
      end
      
      context 'when User with the same :email already exists' do
        before do
          post sign_up_url, params: {
            user: {
              email: user.email,
              name: user_attr[:name],
              password: user_attr[:password],
              password_confirmation: user_attr[:password_confirmation]
            }
          }
        end
        
        it 'should have :unprocessable_entity (422) HTTP response status' do
          expect(response).to have_http_status(422)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return correct errors' do
          expect_json('errors', ['Email has already been taken'])
        end
      end
    end
    
    context 'with invalid params' do
      context 'when :email param is missing' do
        before do
          post sign_up_url, params: {
            user: {
              email: nil,
              name: user_attr[:name],
              password: user_attr[:password],
              password_confirmation: user_attr[:password_confirmation]
            }
          }
        end
        
        it 'should have :unprocessable_entity (422) HTTP response status' do
          expect(response).to have_http_status(422)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return correct errors' do
          expect_json('errors', ["Email can't be blank"])
        end
      end
      
      context 'when :password param is missing' do
        before do
          post sign_up_url, params: {
            user: {
              email: user_attr[:email],
              name: user_attr[:name],
              password: nil,
              password_confirmation: user_attr[:password_confirmation]
            }
          }
        end
        
        it 'should have :unprocessable_entity (422) HTTP response status' do
          expect(response).to have_http_status(422)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return correct errors' do
          expect_json('errors', ["Password can't be blank", "Password confirmation doesn't match Password"])
        end
      end
      
      context "when :password_confirmation doesn't match :password" do
        before do
          post sign_up_url, params: {
            user: {
              email: user_attr[:email],
              name: user_attr[:name],
              password: user_attr[:password],
              password_confirmation: ''
            }
          }
        end
        
        it 'should have :unprocessable_entity (422) HTTP response status' do
          expect(response).to have_http_status(422)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return correct errors' do
          expect_json('errors', ["Password confirmation doesn't match Password"] )
        end
      end
      
      context 'when :name param is missing' do
        before do
          post sign_up_url, params: {
            user: {
              email: user_attr[:email],
              name: nil,
              password: user_attr[:password],
              password_confirmation: user_attr[:password_confirmation]
            }
          }
        end
        
        it 'should have :unprocessable_entity (422) HTTP response status' do
          expect(response).to have_http_status(422)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return correct errors' do
          expect_json('errors', ["Name can't be blank", "Name is too short (minimum is 3 characters)"])
        end
      end
    end
  end
end
