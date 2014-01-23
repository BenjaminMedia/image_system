require 'uuidtools'

module ImageSystem
  module Concerns
    module Image
      extend ActiveSupport::Concern

      attr_accessor :source_file_path

      included do
        validates :uuid, presence: true
        validates :source_file_path, presence: true
        validates :width, presence: true
        validates :height, presence: true
      end
    end
  end
end
