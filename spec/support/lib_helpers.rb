require 'uuidtools'

module LibHelpers
  def create_uuid
    UUIDTools::UUID.random_create.to_s.gsub(/\-/, '')
  end

  def test_image_path
    "#{Rails.root}/public/images/test_image.jpg"
  end

  def stub_model_file(model_name, exists)
    args = File.join(Rails.root, File.join("tmp","app", "models", "#{model_name}.rb"))
    File.should_receive(:exists?).with(args).and_return(exists)
  end

end

RSpec.configure do |config|
  config.include LibHelpers
end
