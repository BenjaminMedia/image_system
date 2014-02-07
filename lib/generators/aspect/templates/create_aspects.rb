class Create<%= class_name.camelize %>Aspects < ActiveRecord::Migration
  def change
    create_table(:<%= class_name %>_aspects) do |t|
      t.string :name
      t.float :aspect_ratio

      t.timestamps
    end
  end
end
