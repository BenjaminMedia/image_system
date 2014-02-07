require 'spec_helper'
require "generators/aspect/aspect_generator"
require "generator_spec"

describe Generators::AspectGenerator do
  destination File.join(Rails.root, "/tmp")

  before(:all) do
    prepare_destination
  end

  after(:each) do
    FileUtils.rm_rf(destination_root + "/app")
    FileUtils.rm_rf(destination_root + "/db")
  end

  it "returns an error if model aspect already exists" do
    stub_model_file_and_unstub_after("picture_aspect", true)
    expect {run_generator %w(picture)}.to raise_error(NameError)
  end

  it "creates the aspect model" do
    run_generator %w(picture)
    assert_file "app/models/picture_aspect.rb", /has_many :picture_crops/
    assert_file "app/models/picture_aspect.rb", /validates :name, presence: true/
    assert_file "app/models/picture_aspect.rb", /validates :aspect_ratio, presence: true/
  end

  it "creates a migration to create a aspects table" do
    run_generator %w(picture)
    assert_migration "db/migrate/create_picture_aspects.rb", /def change/
    assert_migration "db/migrate/create_picture_aspects.rb", /create_table\(:picture_aspects\)/
    assert_migration "db/migrate/create_picture_aspects.rb", /t.string :name/
    assert_migration "db/migrate/create_picture_aspects.rb", /t.float :aspect_ratio/
  end

  it "returns an error if the migration already exists" do
    error_message = "A migration with the name create_picture_aspects already exists please remove it to generate a new one"

    # runs one time to create the migration
    run_generator %w(picture)

    # runs a second time to make sure it raise the exception
    FileUtils.rm_rf(destination_root + "/app")
    expect {run_generator %w(picture)}.to raise_error(NameError, error_message)
  end
end
