class Api::V1::ApiController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
  private
    def record_not_found
      render json: { errors: ['Record not found.'] }, status: :not_found
    end
end
