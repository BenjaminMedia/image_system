require 'spec_helper'

describe ImageSystem::Concerns::Image do

  describe "#validations" do

    it "does not validate an image without the presence of uuid" do
      invalid_photo = Photo.new(source_file_path: test_image_path)
      uuid = nil
      expect(invalid_photo).to_not be_valid
    end

    it "does not validate an image without the presence of source_file_path" do
      invalid_photo = Photo.new(uuid: create_uuid)
      expect(invalid_photo).to_not be_valid
    end

    it "does not validate an image without the presence of width" do
      invalid_photo = Photo.new(uuid: create_uuid, source_file_path: test_image_path)
      invalid_photo.width = nil
      expect(invalid_photo).to_not be_valid
    end

    it "does not validate an image without the presence of height" do
      invalid_photo = Photo.new(uuid: create_uuid, source_file_path: test_image_path)
      invalid_photo.height = nil
      expect(invalid_photo).to_not be_valid
    end

    it "validates an image if uuid and source_file_path is present" do
      valid_photo = Photo.new(uuid: create_uuid, source_file_path: test_image_path, height: 100, width: 100)
      expect(valid_photo).to be_valid
    end
  end

end
