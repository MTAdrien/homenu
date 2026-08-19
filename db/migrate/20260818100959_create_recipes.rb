class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :title
      t.text :instructions
      t.integer :servings
      t.integer :prep_time
      t.string :source
      t.references :household, null: false, foreign_key: true

      t.timestamps
    end
  end
end
