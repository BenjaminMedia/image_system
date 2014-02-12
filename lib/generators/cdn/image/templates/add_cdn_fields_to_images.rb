class AddCdnFieldsTo<%= class_name.camelize.pluralize %> < ActiveRecord::Migration
  def change
    change_table(:<%= class_name.pluralize.downcase %>) do |t|
      t.string  :uuid
      t.integer :width  # width in px
      t.integer :height # height in px
      t.string :file_extension
    end

    add_index :<%= class_name.pluralize.downcase %>, :uuid, unique: true
  end
end
