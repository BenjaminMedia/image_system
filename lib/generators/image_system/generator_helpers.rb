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

    end
  end
end
