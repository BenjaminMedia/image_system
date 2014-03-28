require 'spec_helper'
require "generators/cdn/image/image_generator"
require "generator_spec"

describe Cdn::Generators::ImageGenerator do
  destination File.join(Rails.root, "/tmp")

  before(:all) do
    prepare_destination
  end

  context "When the model exists" do
    before(:each) do
      stub_model_file_and_unstub_after("picture", true)
      run_generator %w(picture)
    end

    it "runs generator and correct files are created" do
      assert_migration "db/migrate/add_cdn_fields_to_pictures.rb", /def change/
      assert_migration "db/migrate/add_cdn_fields_to_pictures.rb", /change_table\(:pictures\)/
      assert_migration "db/migrate/add_cdn_fields_to_pictures.rb", /t.string  :uuid/
      assert_migration "db/migrate/add_cdn_fields_to_pictures.rb", /t.integer :width/
      assert_migration "db/migrate/add_cdn_fields_to_pictures.rb", /t.integer :height/
      assert_migration "db/migrate/add_cdn_fields_to_pictures.rb", /t.string :file_extension/
      assert_migration "db/migrate/add_cdn_fields_to_pictures.rb", /add_index :pictures, :uuid, unique: true/
    end
  end

  context "When the model does not exist" do

    before(:all) do
      run_generator %w(picture)
    end

    it "runs generator and correct files are created" do
      assert_migration "db/migrate/create_pictures_with_cdn_fields.rb", /def change/
      assert_migration "db/migrate/create_pictures_with_cdn_fields.rb", /create_table\(:pictures\)/
      assert_migration "db/migrate/create_pictures_with_cdn_fields.rb", /t.string  :uuid/
      assert_migration "db/migrate/create_pictures_with_cdn_fields.rb", /t.integer :width/
      assert_migration "db/migrate/create_pictures_with_cdn_fields.rb", /t.integer :height/
      assert_migration "db/migrate/create_pictures_with_cdn_fields.rb", /t.string :file_extension/
      assert_migration "db/migrate/create_pictures_with_cdn_fields.rb", /add_index :pictures, :uuid, unique: true/
    end
  end
end

