class CreatePhotoAspects < ActiveRecord::Migration
  def change
    create_table(:photo_aspects) do |t|
      t.string :name
      t.float :aspect_ratio

      t.timestamps
    end
  end
end
