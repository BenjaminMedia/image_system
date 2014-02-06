require 'spec_helper'
require "generators/aspect/aspect_generator"
require "generator_spec"

describe Generators::AspectGenerator do
  destination File.join(Rails.root, "/tmp")

  before(:all) do
    prepare_destination
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
end
