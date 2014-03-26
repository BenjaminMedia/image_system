class Create<%= class_name.camelize.pluralize %>WithCdnFields < ActiveRecord::Migration
  def change
    create_table(:<%= class_name.pluralize.downcase %>) do |t|
      t.string  :uuid
      t.integer :width  # width in px
      t.integer :height # height in px
      t.string :file_extension

      t.timestamps
    end

    add_index :<%= class_name.pluralize.downcase %>, :uuid, unique: true
  end
end
