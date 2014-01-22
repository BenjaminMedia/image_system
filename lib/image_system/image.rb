require 'uuidtools'

module ImageSystem
  module Image

    attr_accessor :source_file_path

    def self.included(base)
      base.class_eval do
        validates :uuid, presence: true
        validates :source_file_path, presence: true
        validates :width, presence: true
        validates :height, presence: true
        before_validation :set_uuid, on: :create
        around_save :upload_to_system
      end
    end

    def destroy
      rescue_from_cdn_failure do
        response = self.new_record? ? true : CDN::CommunicationSystem.delete(uuid: self.uuid)
        super if response
      end
    end

    def url
      begin
         CDN::CommunicationSystem.info(uuid: self.uuid)
      rescue Exceptions::NotFoundException
         return nil
      end

      self.new_record? ? nil : CDN::CommunicationSystem.download(uuid: self.uuid, height: self.height, width: self.width)
    end

  private

    def rescue_from_cdn_failure(&block)
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
      rescue_from_cdn_failure do
        if self.new_record? || self.changed.include?("uuid")
          CDN::CommunicationSystem.upload(uuid: self.uuid, source_file_path: self.source_file_path, queue_processing: false)
        end
        yield
      end
    end

  end
end
