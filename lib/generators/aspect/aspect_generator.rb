require 'rails/generators'
require 'rails/generators/active_record'
require 'generators/image_system/generator_helpers'
require 'generators/image_system/generator_errors'

module Generators
  class AspectGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    include ImageSystem::Generators::GeneratorHelpers
    include ImageSystem::Generators::GeneratorErrors

    desc "This generator creates the aspect model and a migration to add it as a table"

    def self.next_migration_number(path)
      ActiveRecord::Generators::Base.next_migration_number(path)
    end

    source_root File.expand_path('../templates', __FILE__)

    def create_model_and_migrations
      raise NameError.new(aspect_model_already_exists_error) unless model_exists?(destination_root, "aspect")

      template "aspect_model.rb", "app/models/aspect.rb"

      if migration_exists?(destination_root, "create_aspects")
        raise NameError.new(migration_alredy_exists_error("create_aspects"))
      else
        migration_template 'create_aspects.rb', migration_path + "/create_aspects.rb"
      end
    end
  end
end
