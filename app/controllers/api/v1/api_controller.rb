class Api::V1::ApiController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  skip_before_action :verify_authenticity_token
  before_action :authenticate
  
  private
    def authenticate
      # Check access_token presence
      access_token = request.headers['X-Access-Token']
      if access_token.nil?
        render json: { errors: ['No access token'] }, status: :unauthorized
        return
      end
    end
    
    def record_not_found
      render json: {}, status: :not_found
    end
end
