require 'cdnconnect_api'

module ImageSystem
  module CDN
    module CommunicationSystem

      CDN_DEFAULT_JPEG_QUALITY = 95

      def self.upload(options = {})
        options = set_upload_options(options)
        response = api_client.upload(options)
        upload_response(response)
      end

      def self.download(options = {})
        uuid = options.delete(:uuid)
        raise ArgumentError.new("uuid is not set") if uuid.blank?

        file_extension = options.delete(:file_extension)
        raise ArgumentError.new("File extension is not set") if file_extension.blank?

        crop = options.delete(:crop)
        options = options.merge(crop_options(crop))
        options = default_download_options.merge(options)
        params = set_aspect_options(options).delete_if { |k, v| v.nil? }.to_param

        # there is default params so its never gonna be empty
        url_to_image(uuid, file_extension, params)
      end

      def self.rename(options = {})
        uuid = options.delete(:old_uuid)
        new_uuid = options.delete(:new_uuid)
        rename_args_validation(uuid, new_uuid)

        file_extension = options.delete(:file_extension)
        raise ArgumentError.new("File extension is not set") if file_extension.blank?

        options[:path] = "/" + uuid + ".#{file_extension}"
        options[:new_name] = new_uuid + ".#{file_extension}"
        response = api_client.rename_object(options)

        error_handling(response.status)
      end

      def self.delete(options = {})
        uuid = options.delete(:uuid)
        raise ArgumentError.new("uuid is not set") if uuid.blank?

        file_extension = options.delete(:file_extension)
        raise ArgumentError.new("File extension is not set") if file_extension.blank?

        response = api_client.delete_object(path: "/#{uuid}.#{file_extension}")
        error_handling(response.status)
      end

      def self.info(options = {})
        uuid = options.delete(:uuid)
        raise ArgumentError.new("uuid is not set") if uuid.blank?

        file_extension = options.delete(:file_extension)
        raise ArgumentError.new("File extension is not set") if file_extension.blank?

        response = api_client.get_object(path: "/#{uuid}.#{file_extension}")
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

      def self.set_upload_options(options)

        uuid = options.delete(:uuid)
        raise ArgumentError.new("uuid is not set") if uuid.blank?
        file_extension = options.delete(:file_extension)
        raise ArgumentError.new("File extension is not set") if file_extension.blank?

        options[:destination_file_name] = "#{uuid}.#{file_extension}"
        default_upload_options.merge(options)
      end

      def self.set_aspect_options(options = default_download_options)
        aspect = options.delete(:aspect)
        options[:mode] = aspect.to_sym == :original ?  "max" : "crop"
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
          raise ImageSystem::Exceptions::AlreadyExistsException.new("There is an image with the same uuid as the new one")
        when 404
          raise ImageSystem::Exceptions::NotFoundException.new("Does not exist any image with that uuid")
        when 503
          raise ImageSystem::Exceptions::CdnResponseException.new("http_response was nil")
        else
          raise ImageSystem::Exceptions::CdnUnknownException.new("cdn communication system failed")
        end
      end

      def self.upload_response(response)
        result = error_handling(response.status)
        file = response.files.first
        {result: result, width: file["width"], height: file["height"]}
      end

      def self.crop_options(crop)
        return {} unless crop

        exception_message = "Wrong cropping coordinates format. The crop coordinates should be given in the following format { crop: { x1: value, y1: value, x2: value, y2: value } } "
        # checks if all the options are set for cropping
        res = [:x1, :y1, :x2, :y2] - crop.keys

        if res.empty?
          { :crop => "#{crop[:x1]}px,#{crop[:y1]}px,#{crop[:x2]}px,#{crop[:y2]}px" }
        else
          raise ImageSystem::Exceptions::WrongCroppingFormatException.new(exception_message)
        end
      end

      def self.url_to_image(uuid, file_extension, params)
        "http://#{CDN::ApiData::CDN_APP_HOST}/#{uuid}.#{file_extension}" + "?#{params}"
      end

    end
  end
end
