require 'rails/generators'
require 'rails/generators/active_record'

module Generators
  class CropGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc "needs to be defined"

    argument :class_name, :type => :string

    def create_migrations
      raise NameError.new(model_does_exist_error) if model_is_missing?
    end

  private

    def model_does_exist_error
      "The model Picture does not seem to exist. Verify the model exists or run rails g cdn:picture"
    end

    def model_path
      @model_path ||= File.join("app", "models", "#{class_name}.rb")
    end

    def model_is_missing?
      !File.exists?(File.join(destination_root, model_path))
    end

  end
end

