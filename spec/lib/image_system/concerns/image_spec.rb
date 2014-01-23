require 'spec_helper'

describe ImageSystem::Concerns::Image do

  let(:photo) { Photo.new(uuid: create_uuid, source_file_path: test_image_path, height: 100, width: 100) }

  describe "#validations" do

    it "does not validate an image without the presence of uuid" do
      photo.save
      photo.uuid = nil
      expect(photo).to_not be_valid
    end

    it "does not validate an image without the presence of source_file_path" do
      photo.source_file_path = nil
      expect(photo).to_not be_valid
    end

    it "Validate an image without the presence of source_file_path if its not a new record" do
      expect(photo).to be_valid
      photo.save
      photo.source_file_path = nil
      photo.save
      expect(photo).to be_valid
    end

    it "does not validate an image without the presence of width" do
      photo.width = nil
      expect(photo).to_not be_valid
    end

    it "does not validate an image without the presence of height" do
      photo.height = nil
      expect(photo).to_not be_valid
    end

    it "validates an image if uuid and source_file_path is present" do
      expect(photo).to be_valid
    end
  end

  describe "before_validations" do
    it "sets uuid if is not set" do
      new_photo = Photo.create(source_file_path: test_image_path, height: 100, width: 100)
      expect(new_photo.uuid).to_not be_nil
      expect(new_photo).to be_valid
    end

    it "if uuid has been set, should set another one." do
      uuid = photo.uuid
      photo.save
      expect(photo.uuid).to_not eq(uuid)
      expect(photo).to be_valid
    end
  end


end
