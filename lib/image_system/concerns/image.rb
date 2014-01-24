require 'uuidtools'

module ImageSystem
  module Concerns
    module Image
      extend ActiveSupport::Concern

      attr_accessor :source_file_path

      included do
        # validations
        validates :uuid, presence: true
        validates :source_file_path, presence: true, on: :create
        validates :width, presence: true
        validates :height, presence: true

        # callbacks
        before_validation :set_uuid, on: :create
        before_validation :upload_to_system
      end

      def destroy
        rescue_from_cdn_failure_on_destroy do
          response = self.new_record? || CDN::CommunicationSystem.delete(uuid: self.uuid)
          super if response
        end
      end

    private

      def rescue_from_cdn_failure_on_upload(&block)
        begin
          block.call
        rescue Exceptions::CdnResponseException => e
          # should log the problem
          self.errors.add(:image, "The photo could not be uploaded")
        rescue Exceptions::CdnUnknownException => e
          # should log the problem
          self.errors.add(:image, "The photo could not be uploaded")
        end
      end

      def rescue_from_cdn_failure_on_destroy(&block)
        begin
          block.call
        rescue Exceptions::CdnResponseException => e
          # should log the problem
          return false
        rescue Exceptions::CdnUnknownException => e
          # should log the problem
          return false
        end
      end

      def set_uuid
        self.uuid = UUIDTools::UUID.random_create.to_s.gsub(/\-/, '')
      end

      def upload_to_system
        rescue_from_cdn_failure_on_upload do
          if self.new_record? || self.changed.include?("uuid")
            CDN::CommunicationSystem.upload(uuid: self.uuid, source_file_path: self.source_file_path, queue_processing: false)
          end
        end
      end

    end
  end
end
