module ImageSystem
  module Generators
    module GeneratorErrors

      def model_does_not_exists_error(class_name)
        "The model #{class_name.camelize} does not seem to exist. Verify the model exists or run rails g cdn:#{class_name}"
      end

      def crop_model_already_exists_error(class_name)
        "The #{class_name.camelize}Crop model already exists:
          make sure it has a connection to the given class like this

            belongs_to :#{class_name}

          And that it has fields with the coordinates with the following
          names: x1,x2,y1,y2

          If you want to recreate it remove the crop model and table
          and run rails g crop:#{class_name} again and we will create it for you"
      end

      def migration_alredy_exists_error(migration_name)
        "A migration with the name #{migration_name} already exists please remove it to generate a new one"
      end

      def aspect_model_already_exists_error
        "The Aspect model already exists:
          make sure it has a connection to crop like this:

            has_many :crops

          and that it has 2 fields called:

            name and aspec_ratio

          If you want to recreate it remove the aspect model and table
          and run rails g aspect again and we will create it for you"
      end
    end
  end
end
