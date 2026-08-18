class CreateMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :members do |t|
      t.references :household, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
