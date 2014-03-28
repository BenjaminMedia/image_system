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
          migration =  "/add_cdn_fields_to_#{class_name.pluralize.downcase}.rb"
          res = migration_template 'add_cdn_fields_to_images.rb', migration_path + migration unless migration_exists?(destination_root, migration)
        else
          migration = "/create_#{class_name.pluralize.downcase}_with_cdn_fields.rb"
          migration_template 'create_images_with_cdn_fields.rb', migration_path + migration unless migration_exists?(destination_root, migration)
        end
      end
    end
  end
end
