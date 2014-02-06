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
    error_message = "The model Aspect seems to exist. Please delete the model"
    expect {run_generator}.to raise_error(NameError, error_message)
  end

  it "creates the aspect model" do
    stub_model_file_and_unstub_after("aspect", false)
    run_generator
    assert_file "app/models/aspect.rb", /has_many :crops/
    assert_file "app/models/aspect.rb", /validates :name, presence: true/
    assert_file "app/models/aspect.rb", /validates :aspect_ratio, presence: true/
  end

  it "creates a migration to create a aspects table" do
    stub_model_file_and_unstub_after("aspect", false)
    run_generator
    assert_migration "db/migrate/create_aspects.rb", /def change/
    assert_migration "db/migrate/create_aspects.rb", /create_table\(:aspects\)/
    assert_migration "db/migrate/create_aspects.rb", /t.string :name/
    assert_migration "db/migrate/create_aspects.rb", /t.float :aspect_ratio/
  end

  it "returns an error if the migration already exists" do
    # runs one time to create the migration
    error_message = "The migration to create an aspect, seems to exist already. Please remove it!"
    stub_model_file_and_unstub_after("aspect", false)
    run_generator

    # runs a second time to make sure it raise the exception
    stub_model_file_and_unstub_after("aspect", false)
    FileUtils.rm_rf(destination_root + "/app")
    expect {run_generator}.to raise_error(NameError, error_message)
  end
end
