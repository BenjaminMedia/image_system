class CreatePhotoCrops < ActiveRecord::Migration
  def change
    create_table(:photo_crops) do |t|
      t.integer :y1
      t.integer :x1
      t.integer :y2
      t.integer :x2
      t.references :photo, index: true
      t.references :photo_aspect, index: true

      t.timestamps
    end
  end
end