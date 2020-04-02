class TodosController < ApplicationController
  before_action :set_todo, only: [:update, :destroy]
  
  def index
    todos = Todo.order(created_at: :desc)
    render json: todos
  end
  
  def create
    todo = Todo.create(todo_param)
    render json: todo
  end
  
  def update
    @todo.update_attributes(todo_param)
    render json: @todo
  end
  
  def destroy
    @todo.destroy
    head :no_content, status: :ok
  end
  
  private
    def set_todo
      @todo = Todo.find(params[:id])
    end
    
    def todo_param
      params.require(:todo).permit(:title, :done)
    end
end
