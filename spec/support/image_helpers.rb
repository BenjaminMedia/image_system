module ImageHelpers

  def jpg_args
    file_args = { filename: 'test_image.jpg',
                  type: 'image/jpg',
                  tempfile: File.new("#{Rails.root}/public/images/test_image.jpg")
                }
  end

  def jpeg_args
    file_args = { filename: 'jpeg_test_image.jpeg',
                  type: 'image/jpeg',
                  tempfile: File.new("#{Rails.root}/public/images/jpeg_test_image.jpeg")
                }
  end

  def gif_args
    file_args = { filename: 'gif_test_image.gif',
                  type: 'image/gif',
                  tempfile: File.new("#{Rails.root}/public/images/gif_test_image.gif")
                }
  end

  def png_args
    file_args = { filename: 'png_test_image.png',
                  type: 'image/png',
                  tempfile: File.new("#{Rails.root}/public/images/png_test_image.png")
                }
  end

  def uploaded_file(args)
    ActionDispatch::Http::UploadedFile.new(send(args))
  end

  def initialize_api
    @cdn ||= CDNConnect::APIClient.new( app_host: ImageSystem::CDN::ApiData::CDN_APP_HOST,
                                        api_key: ImageSystem::CDN::ApiData::CDN_API_KEY)
  end

end

RSpec.configure do |config|
  config.include ImageHelpers
end
