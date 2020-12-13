class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  
  private
    def respond_with(resource, _opts = {})
      render json: { user: UserSerializer.new(resource).as_json }, status: :ok
    end
    
    def respond_to_on_destroy
      head :no_content
    end
end
