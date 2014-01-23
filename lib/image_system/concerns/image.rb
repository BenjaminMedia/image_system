require 'uuidtools'

module ImageSystem
  module Concerns
    module Image
      extend ActiveSupport::Concern

      attr_accessor :source_file_path

      included do
        validates :uuid, presence: true
        validates :source_file_path, presence: true, on: :create
        validates :width, presence: true
        validates :height, presence: true

        before_validation :set_uuid, on: :create
      end

    private

      def set_uuid
        self.uuid = UUIDTools::UUID.random_create.to_s.gsub(/\-/, '')
      end

    end
  end
end
