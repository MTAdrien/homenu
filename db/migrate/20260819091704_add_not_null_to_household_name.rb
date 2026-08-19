class AddNotNullToHouseholdName < ActiveRecord::Migration[8.1]
  def change
    change_column_null :households, :name, false
  end
end
