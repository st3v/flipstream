class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :title
      t.integer :itunes_id

      t.timestamps
    end
  end
end
