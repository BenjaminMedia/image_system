require 'cdnconnect_api'

module ImageSystem
  module CDN
    module CommunicationSystem

      CDN_DEFAULT_JPEG_QUALITY = 95

      def self.upload(options = {})
        uuid = options.delete(:uuid)
        raise ArgumentError.new("uuid is not set") if uuid.blank?

        options = set_upload_options(uuid, options)
        response = api_client.upload(options)

        upload_response(response)
      end

      def self.download(options = {})
        uuid = options.delete(:uuid)
        raise ArgumentError.new("uuid is not set") if uuid.blank?

        options = default_download_options.merge(options)
        params = set_aspect_options(options).delete_if { |k, v| v.nil? }.to_param

        url = "http://#{CDN::ApiData::CDN_APP_HOST}/#{uuid}.jpg"
        url = url + "?#{params}" unless params.empty?
        url
      end

      def self.rename(options = {})
        uuid = options.delete(:old_uuid)
        new_uuid = options.delete(:new_uuid)
        rename_args_validation(uuid, new_uuid)

        options[:path] = "/" + uuid + ".jpg"
        options[:new_name] = new_uuid + ".jpg"
        response = api_client.rename_object(options)

        error_handling(response.status)
      end

      def self.delete(options = {})
        uuid = options.delete(:uuid)
        raise ArgumentError.new("uuid is not set") if uuid.blank?

        response = api_client.delete_object(path: "/#{uuid}.jpg")
        error_handling(response.status)
      end

      def self.info(options = {})
        uuid = options.delete(:uuid)
        raise ArgumentError.new("uuid is not set") if uuid.blank?

        response = api_client.get_object(path: "/#{uuid}.jpg")
        error_handling(response.status)
      end

    private

      def self.api_client
        @cdn ||= CDNConnect::APIClient.new(app_host: CDN::ApiData::CDN_APP_HOST, api_key: CDN::ApiData::CDN_API_KEY )
      end

      def self.default_upload_options
        { destination_path: '/', queue_processing: false }
      end

      def self.default_download_options
        { quality: CDN_DEFAULT_JPEG_QUALITY, aspect: :original }
      end

      def self.set_upload_options(uuid, options)
        options[:destination_file_name] = "#{uuid}.jpg"
        default_upload_options.merge(options)
      end

      def self.set_aspect_options(options = default_download_options)
        aspect = options.delete(:aspect)
        options[:mode] = aspect == :original ?  "max" : "crop"
        options
      end

      def self.rename_args_validation(uuid, new_uuid)

        to_validate = [["uuid.blank?", "old uuid is not set"],
                       ["new_uuid.blank?", "new uuid is not set"],
                       ["uuid == new_uuid", "old uuid is the same as the new"]]

        to_validate.each do |validation|
          raise ArgumentError.new(validation.last) if eval(validation.first)
        end
      end

      def self.error_handling(status)
        case status
        when 200
          true
        when 400
          raise Exceptions::AlreadyExistsException.new("There is an image with the same uuid as the new one")
        when 404
          raise Exceptions::NotFoundException.new("Does not exist any image with that uuid")
        when 503
          raise Exceptions::CdnResponseException.new("http_response was nil")
        else
          raise Exceptions::CdnUnknownException.new("cdn communication system failed")
        end
      end

      def self.upload_response(response)
        result = error_handling(response.status)
        file = response.files.first
        {result: result, width: file["width"], height: file["height"]}
      end
    end
  end
end
