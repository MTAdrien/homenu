class CreateHouseholds < ActiveRecord::Migration[8.1]
  def change
    create_table :households do |t|
      t.string :name
      t.integer :invite_code
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
