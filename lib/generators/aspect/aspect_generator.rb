require 'rails/generators'
require 'rails/generators/active_record'
require 'generators/image_system/generator_helpers'

module Generators
  class AspectGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    include ImageSystem::Generators::GeneratorHelpers

    desc "needs to be defined"

    def self.next_migration_number(path)
      ActiveRecord::Generators::Base.next_migration_number(path)
    end

    source_root File.expand_path('../templates', __FILE__)

    def create_model_and_migrations
      raise NameError.new(model_already_exists_error) unless model_exists?(destination_root, "aspect")

      template "aspect_model.rb", "app/models/aspect.rb"

      if migration_exists?(destination_root, "create_aspects")
        raise NameError.new(migration_alredy_exists_error)
      else
        migration_template 'create_aspects.rb', migration_path + "/create_aspects.rb"
      end
    end

  private

    def model_already_exists_error
      "The model Aspect seems to exist. Please delete the model"
    end

    def migration_alredy_exists_error
      "The migration to create an aspect, seems to exist already. Please remove it!"
    end
  end
end
