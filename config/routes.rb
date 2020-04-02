Rails.application.routes.draw do
  root 'welcome#index'
  
  namespace :api, shallow: true, constraints: { format: :json } do
    namespace :v1 do
      resources :todos
    end
  end
end
