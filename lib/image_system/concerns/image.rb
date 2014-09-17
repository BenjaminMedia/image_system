require 'uuidtools'

module ImageSystem
  module Concerns
    module Image
      extend ActiveSupport::Concern

      attr_accessor :source_file

      included do

        # Associations
        has_many :crops, dependent: :destroy, class_name: "#{model_name}Crop"

        # Attributes
        attr_readonly :uuid, :width, :height, :file_extension

        # Validations
        validate :check_source_file_content_type, on: :create, if: -> { source_file.present? }

        with_options unless: "source_file.present?" do |image|
          image.validates :uuid, presence: true
          image.validates :width, presence: true
          image.validates :height, presence: true
          image.validates :file_extension, presence: true
        end

        # Callbacks
        with_options if: "source_file.present?" do |image|
          image.before_create :set_uuid
          image.before_create :set_file_extension
          image.before_create :upload_to_system
        end
      end

      def destroy
        if new_record?
          super
        else
          rescue_from_cdn_failure("destroy") do
            CDN::CommunicationSystem.delete(uuid: self.uuid, file_extension: self.file_extension)
            super
          end
        end
      end

      def url(options = {})
        options = set_url_options(options)
        options = set_crop_options_for_url(options)

        if persisted?
          CDN::CommunicationSystem.download(options)
        else
          nil
        end
      end

      def extension_to_content_type_white_list
        []
      end

    private

      def set_url_options(options = {})
        defaults = { width: width, height: height, aspect: :original }
        options = defaults.merge(options)
        options.merge!({ uuid: self.uuid, file_extension: self.file_extension })
      end

      def set_crop_options_for_url(options = {})
        aspect = options[:aspect]
        crop = crops.crop_for(aspect) || "#{self.class.model_name}Crop".constantize.default_crop(self, aspect)
        crop_args = crop ? { crop: { x1: crop.x1, y1: crop.y1, x2: crop.x2, y2: crop.y2 } } : {}
        options.merge!(crop_args)
      end

      def rescue_from_cdn_failure(method, &block)
        begin
          block.call
        rescue ImageSystem::Exceptions::CdnResponseException => e
          # should log the problem
          send("rescue_#{method}_response")
        rescue ImageSystem::Exceptions::CdnUnknownException => e
          # should log the problem
          send("rescue_#{method}_response")
        end
      end

      def set_uuid
        self.uuid = UUIDTools::UUID.random_create.to_s.gsub(/\-/, '')
      end

      def upload_to_system
        rescue_from_cdn_failure("upload") do
          res = CDN::CommunicationSystem.upload(uuid: self.uuid, source_file_path: self.source_file.try(:path), file_extension: self.file_extension)
          self.width = res[:width]
          self.height = res[:height]
        end
      end

      def rescue_upload_response
        self.errors.add(:base, "The photo could not be uploaded")
        false
      end

      def rescue_destroy_response
        false
      end

      def check_source_file_content_type
        content_type = self.source_file.content_type
        errors.add(:source_file, "File type is not allowed #{get_image_type}") unless contente_type_white_list.include?(content_type)
      end

      def set_file_extension
        self.file_extension = get_image_type
      end

      def get_image_type
        self.source_file.content_type.split('/').last
      end

      def contente_type_white_list
        [ 'image/jpg',
          'image/jpeg',
          'image/gif',
          'image/png'
        ] + extension_to_content_type_white_list
      end
    end
  end
end
