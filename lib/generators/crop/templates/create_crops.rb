class CreateCrops < ActiveRecord::Migration
  def change
    create_table(:crops) do |t|
      t.integer :y1
      t.integer :x1
      t.integer :y2
      t.integer :x2
      t.references :<%= class_name %>, index: true

      t.timestamps
    end
  end
end
