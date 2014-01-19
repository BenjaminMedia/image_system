require 'rails/generators'
require 'rails/generators/active_record'

module Generators
  class CropGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc "needs to be defined"

    argument :class_name, :type => :string

    def create_migrations
      raise NameError.new(model_does_exist_error) if model_is_missing?
      raise NameError.new(crop_model_does_exist_error) if crop_model_exists?
    end

  private

    def model_does_exist_error
      "The model Picture does not seem to exist. Verify the model exists or run rails g cdn:picture"
    end

    def crop_model_does_exist_error
      "The crop model already exists:
        make sure it has a connection to the given clas like this

          belongs_to :picture

        And that it has fields with the coordinates with the following
        names: x1,x2,y1,y2

        If you want to recreate it remove the crop model and table
        and run rails g crop:picture again and we will create it for you"
    end

    def model_path
      @model_path ||= File.join("app", "models", "#{class_name}.rb")
    end

    def crop_model_path
      @crop_model_path ||= File.join("app", "models", "crop.rb")
    end

    def model_is_missing?
      !File.exists?(File.join(destination_root, model_path))
    end

    def crop_model_exists?
      File.exists?(File.join(destination_root, crop_model_path))
    end

  end
end

