module ImageSystem
  module Generators
    module GeneratorHelpers

      def models_folder
        @models_folder ||= File.join("app", "models")
      end

      def model_path(model)
        File.join(models_folder, "#{model}.rb")
      end

      def model_exists?(root, model)
        File.exists?(File.join(root, model_path(model)))
      end

      def migration_path
        @migration_path ||= File.join("db", "migrate")
      end

      def migration_exists?(root, migration_name)
        Dir.glob("#{File.join(root, migration_path)}/[0-9]*_*.rb").grep(/\d+_#{migration_name}.rb$/).first
      end

    end
  end
end
