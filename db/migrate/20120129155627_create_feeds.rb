class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :url
      t.string :name
      t.text :description_short
      t.text :description_long
      t.text :keywords
      t.integer :itunes_id
      t.integer :artist_id
      t.integer :genre_id
      t.integer :category_id
      t.integer :subcategory
      t.timestamp :release_date
      t.timestamp :crawl_date
      t.boolean :is_video
      t.boolean :explicit

      t.timestamps
    end
  end
end
