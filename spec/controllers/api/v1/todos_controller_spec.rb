require 'rails_helper'

RSpec.describe Api::V1::TodosController, type: :request do
  let(:api_url) { '/api/v1/todos' }
  let(:user) { FactoryBot.create(:user) }
  
  after :all do
    # Clear DB
    User.destroy_all
  end
  
  describe 'routing', type: :routing do
    it { should route(:get, '/api/v1/todos').to(action: :index, format: :json) }
    it { should route(:get, '/api/v1/todos/:id').to(action: :show, format: :json, id: ':id') }
    it { should route(:post, '/api/v1/todos').to(action: :create, format: :json) }
    it { should route(:patch, '/api/v1/todos/:id').to(action: :update, format: :json, id: ':id') }
    it { should route(:put, '/api/v1/todos/:id').to(action: :update, format: :json, id: ':id') }
    it { should route(:delete, '/api/v1/todos/:id').to(action: :destroy, format: :json, id: ':id') }
  end
  
  describe 'GET #index' do
    before :all do
      @user_1 = FactoryBot.create(:user)
      @user_2 = FactoryBot.create(:user)
      
      # Create 5 Todos for first and 3 for second User
      FactoryBot.create_list(:todo, 5, owner: @user_1)
      FactoryBot.create_list(:todo, 3, owner: @user_2)
    end
    
    context 'when the User is authorized' do
      let(:authorization_token) {
        post '/api/v1/sign_in', params: {
          user: {
            email: @user_1.email,
            password: @user_1.password
          }
        }
        response.headers['Authorization']
      }
      
      before do
        get api_url, headers: { 'Authorization': authorization_token }
      end
      
      it 'should have :ok (200) HTTP response status' do
        expect(response).to have_http_status(200)
      end
      
      it 'should return correct content type' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
      
      it 'should return correct count of Todos, only owned Todos' do
        expect_json_sizes(todos: 5)
      end
      
      it 'should return Todos with correct attributes' do
        expect_json_types('todos.*', completed: :boolean, id: :integer, owner_id: :integer, title: :string)
      end
    end
    
    context 'when the User is NOT authorized' do
      before do
        get api_url
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
  end
  
  describe 'GET #show' do
    before :all do
      @user_1 = FactoryBot.create(:user)
      @user_2 = FactoryBot.create(:user)
      
      # Create 1 Todo for each User
      @todo_1 = FactoryBot.create(:todo, owner: @user_1)
      @todo_2 = FactoryBot.create(:todo, owner: @user_2)
    end
    
    context 'when the User is authorized' do
      let(:authorization_token) {
        post '/api/v1/sign_in', params: {
          user: {
            email: @user_1.email,
            password: @user_1.password
          }
        }
        response.headers['Authorization']
      }
      
      context 'with valid params' do
        before do
          get "#{api_url}/#{@todo_1.id}", headers: { 'Authorization': authorization_token }
        end
        
        it 'should have :ok (200) HTTP response status' do
          expect(response).to have_http_status(200)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return Todo with correct attributes' do
          expect_json_types(todo: { completed: :boolean, id: :integer, owner_id: :integer, title: :string })
        end
      end
      
      context 'with invalid params' do
        context 'when User try get the Todo owned by a different User' do
          before do
            get "#{api_url}/#{@todo_2.id}", headers: { 'Authorization': authorization_token }
          end
          
          it 'should have :not_found (404) HTTP response status' do
            expect(response).to have_http_status(404)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Record not found.')
          end
        end
        
        context 'when Todo with current :id does not exist' do
          before do
            get "#{api_url}/9999999", headers: { 'Authorization': authorization_token }
          end
          
          it 'should have :not_found (404) HTTP response status' do
            expect(response).to have_http_status(404)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Record not found.')
          end
        end
      end
    end
    
    context 'when the User is NOT authorized' do
      before do
        get "#{api_url}/#{@todo_2.id}"
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
  end
  
  describe 'POST #create' do
    context 'when the User is authorized' do
      let(:authorization_token) {
        post '/api/v1/sign_in', params: {
          user: {
            email: user.email,
            password: user.password
          }
        }
        response.headers['Authorization']
      }
      
      context 'with valid params' do
        before do
          post api_url,
          headers: { 'Authorization': authorization_token },
          params: {
            todo: {
              title: Faker::Lorem.sentence
            }
          }
        end
        
        it 'should have :created (201) HTTP response status' do
          expect(response).to have_http_status(201)
        end
        
        it 'should return correct content type' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        
        it 'should return Todo with correct attributes' do
          expect_json_types(todo: { completed: :boolean, id: :integer, owner_id: :integer, title: :string })
        end
      end
      
      context 'with invalid params' do
        context 'when :title is missing' do
          before do
            post api_url,
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                title: nil
              }
            }
          end
          
          it 'should have :unprocessable_entity (422) HTTP response status' do
            expect(response).to have_http_status(422)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', "Title can't be blank")
          end
        end
      end
    end
    
    context 'when the User is NOT authorized' do
      before do
        post api_url, params: {
          todo: {
            title: Faker::Lorem.sentence
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
  end
  
  describe 'PATCH #update' do
    before :all do
      @user_1 = FactoryBot.create(:user)
      @user_2 = FactoryBot.create(:user)
      
      # Create 1 Todo for each User
      @todo_1 = FactoryBot.create(:todo, owner: @user_1)
      @todo_2 = FactoryBot.create(:todo, owner: @user_2)
    end
    
    context 'when the User is authorized' do
      let(:authorization_token) {
        post '/api/v1/sign_in', params: {
          user: {
            email: @user_1.email,
            password: @user_1.password
          }
        }
        response.headers['Authorization']
      }
      
      context 'with valid params' do
        context 'with :title param' do
          before do
            patch "#{api_url}/#{@todo_1.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                title: 'Cool Title'
              }
            }
          end
          
          it 'should have :ok (200) HTTP response status' do
            expect(response).to have_http_status(200)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return Todo with correct attributes' do
            expect_json_types(todo: { completed: :boolean, id: :integer, owner_id: :integer, title: :string })
          end
          
          it 'should update :title in Todo' do
            expect(@todo_1.reload.title).to eq('Cool Title')
          end
        end
        
        context 'with :completed param' do
          before do
            patch "#{api_url}/#{@todo_1.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                completed: true
              }
            }
          end
          
          it 'should have :ok (200) HTTP response status' do
            expect(response).to have_http_status(200)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return Todo with correct attributes' do
            expect_json_types(todo: { completed: :boolean, id: :integer, owner_id: :integer, title: :string })
          end
          
          it 'should update :completed in Todo' do
            expect(@todo_1.reload.completed).to eq(true)
          end
        end
      end
      
      context 'with invalid params' do
        context 'when User try to update Todo owned by different User' do
          before do
            patch "#{api_url}/#{@todo_2.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                title: nil
              }
            }
          end
          
          it 'should have :not_found (404) HTTP response status' do
            expect(response).to have_http_status(404)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Record not found.')
          end
        end
        
        context 'when Todo with current :id is missing' do
          before do
            patch "#{api_url}/999999999",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                title: nil
              }
            }
          end
          
          it 'should have :not_found (404) HTTP response status' do
            expect(response).to have_http_status(404)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Record not found.')
          end
        end
        
        context 'when :title is missing' do
          before do
            patch "#{api_url}/#{@todo_1.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                title: nil
              }
            }
          end
          
          it 'should have :unprocessable_entity (422) HTTP response status' do
            expect(response).to have_http_status(422)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', "Title can't be blank")
          end
        end
        
        context 'when :completed is missing' do
          before do
            patch "#{api_url}/#{@todo_1.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                completed: nil
              }
            }
          end
          
          it 'should have :unprocessable_entity (422) HTTP response status' do
            expect(response).to have_http_status(422)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Completed is not included in the list')
          end
        end
      end
    end
    
    context 'when the User is NOT authorized' do
      before do
        post api_url, params: {
          todo: {
            title: Faker::Lorem.sentence
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
  end
  
  describe 'PUT #update' do
    before :all do
      @user_1 = FactoryBot.create(:user)
      @user_2 = FactoryBot.create(:user)
      
      # Create 1 Todo for each User
      @todo_1 = FactoryBot.create(:todo, owner: @user_1)
      @todo_2 = FactoryBot.create(:todo, owner: @user_2)
    end
    
    context 'when the User is authorized' do
      let(:authorization_token) {
        post '/api/v1/sign_in', params: {
          user: {
            email: @user_1.email,
            password: @user_1.password
          }
        }
        response.headers['Authorization']
      }
      
      context 'with valid params' do
        context 'with :title param' do
          before do
            put "#{api_url}/#{@todo_1.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                title: 'Cool Title'
              }
            }
          end
          
          it 'should have :ok (200) HTTP response status' do
            expect(response).to have_http_status(200)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return Todo with correct attributes' do
            expect_json_types(todo: { completed: :boolean, id: :integer, owner_id: :integer, title: :string })
          end
          
          it 'should update :title in Todo' do
            expect(@todo_1.reload.title).to eq('Cool Title')
          end
        end
        
        context 'with :completed param' do
          before do
            put "#{api_url}/#{@todo_1.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                completed: true
              }
            }
          end
          
          it 'should have :ok (200) HTTP response status' do
            expect(response).to have_http_status(200)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return Todo with correct attributes' do
            expect_json_types(todo: { completed: :boolean, id: :integer, owner_id: :integer, title: :string })
          end
          
          it 'should update :completed in Todo' do
            expect(@todo_1.reload.completed).to eq(true)
          end
        end
      end
      
      context 'with invalid params' do
        context 'when User try to update Todo owned by different User' do
          before do
            put "#{api_url}/#{@todo_2.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                title: nil
              }
            }
          end
          
          it 'should have :not_found (404) HTTP response status' do
            expect(response).to have_http_status(404)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Record not found.')
          end
        end
        
        context 'when Todo with current :id is missing' do
          before do
            put "#{api_url}/999999999",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                title: nil
              }
            }
          end
          
          it 'should have :not_found (404) HTTP response status' do
            expect(response).to have_http_status(404)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Record not found.')
          end
        end
        
        context 'when :title is missing' do
          before do
            put "#{api_url}/#{@todo_1.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                title: nil
              }
            }
          end
          
          it 'should have :unprocessable_entity (422) HTTP response status' do
            expect(response).to have_http_status(422)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', "Title can't be blank")
          end
        end
        
        context 'when :completed is missing' do
          before do
            put "#{api_url}/#{@todo_1.id}",
            headers: { 'Authorization': authorization_token },
            params: {
              todo: {
                completed: nil
              }
            }
          end
          
          it 'should have :unprocessable_entity (422) HTTP response status' do
            expect(response).to have_http_status(422)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Completed is not included in the list')
          end
        end
      end
    end
    
    context 'when the User is NOT authorized' do
      before do
        post api_url, params: {
          todo: {
            title: Faker::Lorem.sentence
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
  end
  
  describe 'DELETE #destroy' do
    let(:user_1) { FactoryBot.create(:user) }
    let(:user_2) { FactoryBot.create(:user) }
    let(:todo_1) { FactoryBot.create(:todo, owner: user_1) }
    let(:todo_2) { FactoryBot.create(:todo, owner: user_2) }
    
    context 'when the User is authorized' do
      let(:authorization_token) {
        post '/api/v1/sign_in', params: {
          user: {
            email: user_1.email,
            password: user_1.password
          }
        }
        response.headers['Authorization']
      }
      
      context 'with valid params' do
        before do
          delete "#{api_url}/#{todo_1.id}", headers: { 'Authorization': authorization_token }
        end
        
        it 'should have :no_content (204) HTTP response status' do
          expect(response).to have_http_status(204)
        end
        
        it 'should destroy Todo' do
          expect(user.own_todos.count).to eq(0)
        end
      end
      
      context 'with invalid params' do
        context 'when User try to update Todo owned by different User' do
          before do
            delete "#{api_url}/#{todo_2.id}", headers: { 'Authorization': authorization_token }
          end
          
          it 'should have :not_found (404) HTTP response status' do
            expect(response).to have_http_status(404)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Record not found.')
          end
        end
        
        context 'when Todo with current :id is missing' do
          before do
            delete "#{api_url}/999999999", headers: { 'Authorization': authorization_token }
          end
          
          it 'should have :not_found (404) HTTP response status' do
            expect(response).to have_http_status(404)
          end
          
          it 'should return correct content type' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          
          it 'should return correct error' do
            expect_json('errors.*', 'Record not found.')
          end
        end
      end
    end
    
    context 'when the User is NOT authorized' do
      before do
        delete "#{api_url}/#{todo_1.id}"
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
  end
end
