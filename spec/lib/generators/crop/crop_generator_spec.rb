require 'spec_helper'
require "generators/crop/crop_generator"
require "generator_spec"

describe Generators::CropGenerator do
  destination File.join(Rails.root, "/tmp")

  before(:all) do
    prepare_destination
  end

  after(:each) do
    FileUtils.rm_rf(destination_root + "/app")
    FileUtils.rm_rf(destination_root + "/db")
  end

  it "returns an error if the given class does not exist" do
    error_message = "The model Picture does not seem to exist. Verify the model exists or run rails g cdn:picture"
    expect {run_generator %w(picture)}.to raise_error(NameError, error_message)
  end

  it "returns an error if the crop model exists" do
    stub_model_file_and_unstub_after("picture", true)
    stub_model_file("crop", true)

    expect {run_generator %w(picture)}.to raise_exception(NameError)
  end

  it "creates a crop model" do
    stub_model_file_and_unstub_after("picture", true)
    run_generator %w(picture)
    assert_file "app/models/crop.rb", /belongs_to :picture/
  end

  it "creates a migration to create the crop table" do
    stub_model_file_and_unstub_after("picture", true)
    run_generator %w(picture)
    assert_migration "db/migrate/create_crops.rb", /def change/
    assert_migration "db/migrate/create_crops.rb", /create_table\(:crops\)/
  end

  it "returns an error if the migration already exists" do
    # runs one time to create the migration
    error_message = "A migration with the name create crops already exists please remove it to generate a new one"
    stub_model_file_and_unstub_after("picture", true)
    run_generator %w(picture)

    # runs a second time to make sure it raise the exception
    stub_model_file_and_unstub_after("picture", true)
    FileUtils.rm_rf(destination_root + "/app")
    expect {run_generator %w(picture)}.to raise_exception(NameError, error_message)
  end

  it "adds an id field as part of the migration name" do
    stub_model_file_and_unstub_after("picture", true)
    run_generator %w(picture)
    assert_migration "db/migrate/create_crops.rb", /t.references :picture, index: true/
  end
end
