class AddFirstNameAndRoleToMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :members, :first_name, :string
    add_column :members, :role, :string
  end
end
