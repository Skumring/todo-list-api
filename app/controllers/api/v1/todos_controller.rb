class Api::V1::TodosController < Api::V1::ApiController
  before_action :set_todo, only: [:show, :update, :destroy]
  
  # GET /api/v1/todos
  def index
    render json: { todos: ActiveModel::Serializer::CollectionSerializer.new(current_user.own_todos.order(created_at: :desc), serializer: TodoSerializer).as_json }, status: :ok
  end
  
  # GET /api/v1/todos/:id
  def show
    render json: { todo: TodoSerializer.new(@todo).as_json }, status: :ok
  end
  
  # POST /api/v1/todos
  def create
    todo = current_user.own_todos.build(todo_params)
    if todo.save
      render json: { todo: TodoSerializer.new(todo).as_json }, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /api/v1/todos/:id
  def update
    if @todo.update(todo_params)
      render json: { todo: TodoSerializer.new(@todo).as_json }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v1/todos/:id
  def destroy
    if @todo.destroy
      head :no_content
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
    def set_todo
      @todo = current_user.own_todos.find_by!(id: params[:id])
    end
    
    def todo_params
      params.require(:todo).permit(:completed, :title)
    end
end
