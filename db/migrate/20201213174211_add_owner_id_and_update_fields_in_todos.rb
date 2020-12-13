class AddOwnerIdAndUpdateFieldsInTodos < ActiveRecord::Migration[6.0]
  def up
    # Clear DB to make sure about already existing Todos will be destroyed
    Todo.destroy_all
    
    remove_column :todos, :done
    change_column :todos, :title, :string, null: false
    
    add_column :todos, :completed, :boolean, null: false, default: false
    add_column :todos, :owner_id, :bigint, null: false
    add_index :todos, :owner_id
  end
  
  def down
    remove_column :todos, :completed
    remove_column :todos, :owner_id
    change_column :todos, :title, :string, null: true
    
    add_column :todos, :done, :boolean
  end
end
