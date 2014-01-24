require 'spec_helper'

describe ImageSystem::Concerns::Image do

  let(:new_photo) { build(:photo, uuid: create_uuid, source_file_path: test_image_path, height: 100, width: 100) }
  let(:photo) { create(:photo, uuid: create_uuid, source_file_path: test_image_path, height: 100, width: 100) }

  describe "#validations" do

    before(:each) do
      ImageSystem::CDN::CommunicationSystem.stub(:upload)
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
      new_photo.width = nil
      expect(new_photo).to_not be_valid
    end

    it "does not validate an image without the presence of height" do
      new_photo.height = nil
      expect(new_photo).to_not be_valid
    end

    it "validates an image if uuid and source_file_path is present" do
      expect(new_photo).to be_valid
    end
  end

  describe "before_validations" do

    describe "set_uuid" do

      before(:each) do
        ImageSystem::CDN::CommunicationSystem.stub(:upload)
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
        expect(new_photo.save).to eq(false)
        expect(new_photo.errors.full_messages).to eq(["Image The photo could not be uploaded"])
      end

      it "does not save an image that is new and has not been uploaded successfully for unknown reasons" do
        ImageSystem::CDN::CommunicationSystem.stub(:upload).and_raise(Exceptions::CdnUnknownException.new("cdn communication system failed"))
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload)
        expect(new_photo.save).to eq(false)
        expect(new_photo.errors.full_messages).to eq(["Image The photo could not be uploaded"])
      end

      it "saves an image that is new and has been uploaded successfully" do
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload)
        expect(new_photo.save).to eq(true)
      end

      it "does not upload a new image that is not a new record and does not have a new uuid" do
        ImageSystem::CDN::CommunicationSystem.stub(:upload)
        expect(photo).to_not be_a_new_record

        ImageSystem::CDN::CommunicationSystem.should_not_receive(:upload)
        expect(photo.save).to eq(true)
      end

      it "uploads the image if its not a new record but has a new uuid" do
        ImageSystem::CDN::CommunicationSystem.stub(:upload)
        expect(photo).to_not be_a_new_record

        photo.uuid = create_uuid
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload)
        expect(photo.save).to eq(true)
      end
    end
  end


  describe "#destroy" do

     before(:each) do
      ImageSystem::CDN::CommunicationSystem.stub(:upload)
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
      expect(photo.destroy).to eq(false)
    end

    it  "does not delete an image if there isn't a response from the server" do
      ImageSystem::CDN::CommunicationSystem.stub(:delete).and_raise(Exceptions::CdnResponseException.new("http_response was nil"))
      ImageSystem::CDN::CommunicationSystem.should_receive(:delete)
      expect(photo.destroy).to eq(false)
    end
  end

  # describe "#url" do

  #   it "returns an url to the image with the given uuid" do
  #     Photo.any_instance.stub(:new_record?) { false }
  #     CDN::CommunicationSystem.stub(:info)
  #     CDN::CommunicationSystem.should_receive(:download)
  #     photo.url
  #   end

  #   it "returns nil if image is a new record" do
  #     Photo.any_instance.stub(:new_record?) { true }
  #     CDN::CommunicationSystem.stub(:info)
  #     expect(photo.url).to be_nil
  #   end

  #   it "returns nil if the object does not exist" do
  #     Photo.any_instance.stub(:new_record?) { false }
  #     CDN::CommunicationSystem.stub(:info).with({ uuid: new_photo.uuid }).and_raise(Exceptions::NotFoundException.new("Does not exist any image with that uuid"))
  #     expect(new_photo.url).to be_nil
  #   end
  # end

end
