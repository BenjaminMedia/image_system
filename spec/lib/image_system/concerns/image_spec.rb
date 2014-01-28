require 'spec_helper'

describe ImageSystem::Concerns::Image do

  let(:new_photo) { build(:photo, uuid: create_uuid, source_file_path: test_image_path) }
  let(:new_photo_to_upload) { build(:photo, source_file_path: test_image_path) }
  let(:photo) { create(:photo, uuid: create_uuid, source_file_path: test_image_path) }

  describe "#validations" do

    before(:each) do
      ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
    end

    it "does not validate an image without the presence of uuid" do
      photo.uuid = nil
      expect(photo).to_not be_valid
    end

    it "does not validate an image without the presence of source_file_path" do
      new_photo.source_file_path = nil
      expect(new_photo).to_not be_valid
    end

    it "Validate an image without the presence of source_file_path if its not a new record" do
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
      expect(new_photo).to be_valid
    end
  end

  describe "before_validations" do

    describe "set_uuid" do

      before(:each) do
        ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
      end

      it "sets uuid if is not set" do
        expect(new_photo.uuid).to_not be_nil
        expect(new_photo).to be_valid
      end

      it "if uuid has been set, should set another one." do
        uuid = new_photo.uuid
        new_photo.save
        expect(new_photo.uuid).to_not eq(uuid)
        expect(new_photo).to be_valid
      end
    end

    describe "upload_to_system" do

      it "does not save an image that is new and has not received a response from cdn" do
        ImageSystem::CDN::CommunicationSystem.stub(:upload).and_raise(Exceptions::CdnResponseException.new("http_response was nil"))
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload)
        expect(new_photo_to_upload.save).to eq(false)
        expect(new_photo_to_upload.errors.full_messages).to include("Image The photo could not be uploaded")
      end

      it "does not save an image that is new and has not been uploaded successfully for unknown reasons" do
        ImageSystem::CDN::CommunicationSystem.stub(:upload).and_raise(Exceptions::CdnUnknownException.new("cdn communication system failed"))
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload)
        expect(new_photo_to_upload.save).to eq(false)
        expect(new_photo_to_upload.errors.full_messages).to include("Image The photo could not be uploaded")
      end

      it "saves an image that is new and has been uploaded successfully" do
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload).and_return({result: true , height: 100, width: 100})
        expect(new_photo_to_upload.save).to eq(true)
      end

      it "does not upload a new image that is not a new record and does not have a new uuid" do
        ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
        expect(photo).to_not be_a_new_record

        ImageSystem::CDN::CommunicationSystem.should_not_receive(:upload)
        expect(photo.save).to eq(true)
      end

      it "uploads the image if its not a new record but has a new uuid" do
        ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
        expect(photo).to_not be_a_new_record

        photo.uuid = create_uuid
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload)
        expect(photo.save).to eq(true)
      end

      it "sets the height and width if upload is correct" do
        expect(new_photo_to_upload.height).to be_nil
        expect(new_photo_to_upload.width).to be_nil
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload).and_return({result: true , height: 100, width: 100})
        expect(new_photo_to_upload.save).to eq(true)
      end
    end
  end


  describe "#destroy" do

    before(:each) do
      ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
    end

    it  "deletes an image if it is deleted successfully from the server" do
      ImageSystem::CDN::CommunicationSystem.stub(:delete) { true }
      ImageSystem::CDN::CommunicationSystem.should_receive(:delete)
      expect(photo.destroy).to eq(photo)
    end

    it "does not delete an image that is a new record" do
      ImageSystem::CDN::CommunicationSystem.should_not_receive(:delete)
      expect(new_photo.destroy).to eq(new_photo)
    end

    it  "does not delete an image if there is an unknown error from the server" do
      ImageSystem::CDN::CommunicationSystem.stub(:delete).and_raise(Exceptions::CdnUnknownException.new("cdn communication system failed"))
      ImageSystem::CDN::CommunicationSystem.should_receive(:delete)
      expect(photo.destroy).to eq(nil)
    end

    it  "does not delete an image if there isn't a response from the server" do
      ImageSystem::CDN::CommunicationSystem.stub(:delete).and_raise(Exceptions::CdnResponseException.new("http_response was nil"))
      ImageSystem::CDN::CommunicationSystem.should_receive(:delete)
      expect(photo.destroy).to eq(nil)
    end
  end

  describe "#url" do

    before(:each) do
      ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
    end

    it "returns an url to the image with the given uuid" do
      ImageSystem::CDN::CommunicationSystem.stub(:info)
      ImageSystem::CDN::CommunicationSystem.should_receive(:download)
      photo.url
    end

    it "returns nil if image is a new record" do
      ImageSystem::CDN::CommunicationSystem.stub(:info)
      ImageSystem::CDN::CommunicationSystem.should_not_receive(:download)
      expect(new_photo.url).to be_nil
    end

    it "returns nil if the object does not exist" do
      ImageSystem::CDN::CommunicationSystem.stub(:info).with({ uuid: photo.uuid }).and_raise(Exceptions::NotFoundException.new("Does not exist any image with that uuid"))
      ImageSystem::CDN::CommunicationSystem.should_not_receive(:download)
      expect(photo.url).to be_nil
    end
  end

end
