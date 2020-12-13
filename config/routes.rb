Rails.application.routes.draw do
  root 'welcome#index'
  
  devise_for :users,
    defaults: { format: :json },
    path: '/api/v1/',
    path_names: {
      sign_in: 'sign_in',
      sign_out: 'sign_out',
      registration: 'sign_up'
    },
    controllers: {
      sessions: 'api/v1/sessions',
      registrations: 'api/v1/registrations'
    }
  
  namespace :api, shallow: true, defaults: { format: :json } do
    namespace :v1 do
      resources :todos
    end
  end
end
