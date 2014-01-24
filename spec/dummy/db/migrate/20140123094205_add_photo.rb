class AddPhoto < ActiveRecord::Migration
  def change
    create_table(:photos) do |t|
      t.string  :uuid
      t.integer :width  # width in px
      t.integer :height # height in px

      t.timestamps
    end

    add_index :photos, :uuid, unique: true
  end
end
