require 'spec_helper'
require "generators/crop/crop_generator"
require "generator_spec"

describe Generators::CropGenerator do
  destination File.join(Rails.root, "/tmp")

  before(:all) do
    prepare_destination
  end

  it "returns an error if the given class does not exist" do
    error_message = "The model Picture does not seem to exist. Verify the model exists or run rails g cdn:picture"
    stub_model_file("picture", false)

    expect {run_generator %w(picture)}.to raise_error(NameError, error_message)
  end

  it "returns an error if the crop model exists" do

    stub_model_file("picture", true)
    stub_model_file("crop", true)

    expect {run_generator %w(picture)}.to raise_exception(NameError)
  end

end
