require 'rails/generators'
require 'rails/generators/active_record'
require 'generators/image_system/generator_helpers'

module Cdn
  module Generators
    class ImageGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      include ImageSystem::Generators::GeneratorHelpers

      desc "Adds the necessary fields to the CLASS_NAME table in order to work as a CDN image"

      argument :class_name, :type => :string

      source_root File.expand_path('../templates', __FILE__)

      def self.next_migration_number(path)
        ActiveRecord::Generators::Base.next_migration_number(path)
      end

      def create_migrations
        if model_exists?(destination_root, class_name)
          path = migration_path("add_cdn_fields_to_#{class_name.pluralize.downcase}")
          migration_template 'add_cdn_fields_to_images.rb', path unless migration_exists?(path)
        else
          path = migration_path("create_#{class_name.pluralize.downcase}_with_cdn_fields")
          migration_template 'create_images_with_cdn_fields.rb', path unless migration_exists?(path)
        end
      end

    private

      def migration_path(name)
        File.join("db", "migrate", "#{name}.rb")
      end

      def migration_exists?(path)
        File.exists?(File.join(destination_root, path))
      end

    end
  end
end
