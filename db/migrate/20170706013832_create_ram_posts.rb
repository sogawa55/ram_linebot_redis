class CreateRamPosts < ActiveRecord::Migration
  def change
    create_table :ram_posts do |t|
      t.text :words

      t.timestamps null: false
    end
  end
end
