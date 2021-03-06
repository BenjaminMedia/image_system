require 'rails/generators'
require 'rails/generators/active_record'
require 'generators/image_system/generator_helpers'
require 'generators/image_system/generator_errors'


class CropGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  include ImageSystem::Generators::GeneratorHelpers
  include ImageSystem::Generators::GeneratorErrors

  desc "This adds a crop model and the migrations to create the relation with the given class name"

  argument :class_name, :type => :string

  def self.next_migration_number(path)
    ActiveRecord::Generators::Base.next_migration_number(path)
  end

  source_root File.expand_path('../templates', __FILE__)

  def creates_model_and_migrations
    raise NameError.new(model_does_not_exists_error(class_name)) unless model_exists?(destination_root, class_name)
    raise NameError.new(crop_model_already_exists_error(class_name)) if model_exists?(destination_root, "#{class_name}_crop")

    template "crop_model.rb", "app/models/#{class_name}_crop.rb"

    if migration_exists?(destination_root, "create_#{class_name}_crops")
      raise NameError.new(migration_alredy_exists_error("create_#{class_name}_crops"))
    else
      migration_template 'create_crops.rb', migration_path + "/create_#{class_name}_crops.rb"
    end
  end
end
