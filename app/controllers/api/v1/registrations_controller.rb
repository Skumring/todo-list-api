class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  
  # POST /api/v1/sign_up
  def create
    build_resource(sign_up_params)
    if resource.save
      sign_in(resource_name, resource)
      render json: { user: UserSerializer.new(resource).as_json }, status: :created
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
