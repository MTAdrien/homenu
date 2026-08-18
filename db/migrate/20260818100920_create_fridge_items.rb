class CreateFridgeItems < ActiveRecord::Migration[8.1]
  def change
    create_table :fridge_items do |t|
      t.string :name
      t.integer :quantity
      t.date :expiry_date
      t.references :household, null: false, foreign_key: true

      t.timestamps
    end
  end
end
