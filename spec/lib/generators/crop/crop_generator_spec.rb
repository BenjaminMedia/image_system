require 'spec_helper'
require "generators/crop/crop_generator"
require "generator_spec"

describe Generators::CropGenerator do
  destination File.expand_path("../../tmp", __FILE__)

  before(:all) do
    prepare_destination
  end

  it "returns an error if the given class does not exist" do
    error_message = "The model Picture does not seem to exist. Verify the model exists or run rails g cdn:picture"
    @args = File.join(File.expand_path("../../tmp", __FILE__), File.join("app", "models", "picture.rb"))
    File.should_receive(:exists?).with(@args).and_return(false)
    expect {run_generator %w(picture)}.to raise_error(NameError, error_message)
  end

end
