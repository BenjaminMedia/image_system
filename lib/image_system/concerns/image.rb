require 'uuidtools'

module ImageSystem
  module Concerns
    module Image
      extend ActiveSupport::Concern

      attr_accessor :source_file

      included do
        # Validations
        validates :uuid, presence: true
        validates :source_file, presence: true, on: :create
        validates :width, presence: true
        validates :height, presence: true
        validates :file_extension, presence: true

        # Callbacks
        before_validation :check_source_file_content_type, on: :create, if: "source_file.present?"
        before_validation :set_uuid, on: :create
        before_validation :upload_to_system
      end

      def destroy
        response = rescue_from_cdn_failure("destroy") do
          self.new_record? || CDN::CommunicationSystem.delete(uuid: self.uuid, file_extension: self.file_extension)
        end
        super if response
      end

      def url
        begin
           CDN::CommunicationSystem.info(uuid: self.uuid, file_extension: self.file_extension)
        rescue Exceptions::NotFoundException
           return nil
        end

        self.new_record? ? nil : CDN::CommunicationSystem.download(uuid: self.uuid, file_extension: self.file_extension)
      end

      def extension_to_content_type_white_list
        []
      end

    private

      def rescue_from_cdn_failure(method, &block)
        begin
          block.call
        rescue Exceptions::CdnResponseException => e
          # should log the problem
          send("rescue_#{method}_response")
        rescue Exceptions::CdnUnknownException => e
          # should log the problem
          send("rescue_#{method}_response")
        end
      end

      def set_uuid
        self.uuid = UUIDTools::UUID.random_create.to_s.gsub(/\-/, '')
      end

      def upload_to_system
        rescue_from_cdn_failure("upload") do
          if self.new_record? || self.changed.include?("uuid")
            res = CDN::CommunicationSystem.upload(uuid: self.uuid, source_file_path: self.source_file.try(:path), file_extension: self.file_extension)
            self.width = res[:width]
            self.height = res[:height]
          end
        end
      end

      def rescue_upload_response
        self.errors.add(:image, "The photo could not be uploaded")
      end

      def rescue_destroy_response
        false
      end

      def check_source_file_content_type
        content_type = self.source_file.content_type
        type = content_type.split('/').last
        if contente_type_white_list.include?(content_type)
          self.file_extension = type
        else
          errors.add(:source_file, "File type is not allowed #{type}")
        end
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
