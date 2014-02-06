require 'rails/generators'
require 'rails/generators/active_record'
require 'generators/image_system/generator_helpers'

module Generators
  class AspectGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    include ImageSystem::Generators::GeneratorHelpers

    desc "needs to be defined"

    source_root File.expand_path('../templates', __FILE__)

    def create_model_and_migrations
      raise NameError.new(model_already_exists_error) unless model_exists?(destination_root, "aspect")
    end

  private

    def model_already_exists_error
      "The model Aspect seems to exist. Please delete the model"
    end
  end
end
