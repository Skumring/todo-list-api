require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :request do
  describe 'routing', type: :routing do
    it { should route(:post, '/api/v1/sign_in').to(action: :create, format: :json) }
    it { should route(:delete, '/api/v1/sign_out').to(action: :destroy, format: :json) }
  end
  
  describe 'POST #sign_in' do
    let(:user) { FactoryBot.create(:user) }
    let(:user_attr) { FactoryBot.attributes_for(:user) }
    let(:sign_in_url) { '/api/v1/sign_in' }
    
    context 'with valid params' do
      context 'when User with the same credentials already exists' do
        before do
          post sign_in_url, params: {
            user: {
              email: user.email,
              password: user.password
            }
          }
        end
        
        it 'should have :ok (200) HTTP response status' do
          expect(response).to have_http_status(200)
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
    end
    
    context 'with invalid params' do
      context 'when User with the same :email already exists but password did not match' do
        before do
          post sign_in_url, params: {
            user: {
              email: user.email,
              password: 'fake_password'
            }
          }
        end
        
        it 'should have :unauthorized (401) HTTP response status' do
          expect(response).to have_http_status(401)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return correct error' do
          expect_json('error', 'Invalid Email or password.')
        end
      end
      
      context 'when :email param is missing' do
        before do
          post sign_in_url, params: {
            user: {
              email: nil,
              password: user.password
            }
          }
        end
        
        it 'should have :unauthorized (401) HTTP response status' do
          expect(response).to have_http_status(401)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return correct error' do
          expect_json('error', 'You need to sign in or sign up before continuing.')
        end
      end
      
      context 'when :password param is missing' do
        before do
          post sign_in_url, params: {
            user: {
              email: user.email,
              password: nil
            }
          }
        end
        
        it 'should have :unauthorized (401) HTTP response status' do
          expect(response).to have_http_status(401)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return correct error' do
          expect_json('error', 'Invalid Email or password.')
        end
      end
    end
  end
  
  describe 'DELETE #sign_out' do
    let(:user) { FactoryBot.create(:user) }
    let(:sign_out_url) { '/api/v1/sign_out' }
    let(:authorization_token) {
      post '/api/v1/sign_in', params: {
        user: {
          email: user.email,
          password: user.password
        }
      }
      response.headers['Authorization']
    }
    
    context 'when User already authorized and send the correct authorization token' do
      before do
        delete sign_out_url, headers: { 'Authorization': authorization_token }
      end
      
      it 'should have :no_content (204) HTTP response status' do
        expect(response).to have_http_status(204)
      end
      
      it 'should destroy authorized User session' do
        expect(user.allowlisted_jwts.count).to eq(0)
      end
    end
    
    context 'when User already authorized but send the invalid authorization token' do
      before do
        authorization_token
        delete sign_out_url, headers: { 'Authorization': SecureRandom.hex(4) }
      end
      
      it 'should have :no_content (204) HTTP response status' do
        expect(response).to have_http_status(204)
      end
      
      it 'should NOT destroy authorized User session' do
        expect(user.allowlisted_jwts.count).to eq(1)
      end
    end
    
    context 'when User already authorized but authorization token is missing' do
      before do
        authorization_token
        delete sign_out_url
      end
      
      it 'should have :no_content (204) HTTP response status' do
        expect(response).to have_http_status(204)
      end
      
      it 'should NOT destroy authorized User session' do
        expect(user.allowlisted_jwts.count).to eq(1)
      end
    end
    
    context 'when User is not authorized' do
      before do
        delete sign_out_url
      end
      
      it 'should have :no_content (204) HTTP response status' do
        expect(response).to have_http_status(204)
      end
    end
  end
end
