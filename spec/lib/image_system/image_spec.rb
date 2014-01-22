require 'spec_helper'

module ImageSystem

  describe "Image" do

    let(:photo) { Photo.new(uuid: create_uuid, source_file_path: test_image_path, width: 100, height: 100) }
    let(:new_photo) { Photo.new(source_file_path: test_image_path, width: 100, height: 100) }

    describe "#validations" do
      it "does not save an image without the presence of uuid" do
        invalid_photo = Photo.new(source_file_path: test_image_path, width: 100, height: 100)
        expect(invalid_photo).to_not be_valid
      end

      it "does not save an image without the presence of source_file_path" do
        invalid_photo = Photo.new(uuid: create_uuid, width: 100, height: 100)
        expect(invalid_photo).to_not be_valid
      end

      it "does not save an image without the presence of width" do
        invalid_photo = Photo.new(uuid: create_uuid, source_file_path: test_image_path, height: 100)
        expect(invalid_photo).to_not be_valid
      end

      it "does not save an image without the presence of height" do
        invalid_photo = Photo.new(uuid: create_uuid, source_file_path: test_image_path, width: 100)
        expect(invalid_photo).to_not be_valid
      end

      it "saves an image if uuid and source_file_path is present" do
        valid_photo = Photo.new(uuid: create_uuid, source_file_path: test_image_path, width: 100, height: 100)
        expect(valid_photo).to be_valid
      end
    end

    describe "around_save" do
      it "sets uuid if is not set" do
        Photo.any_instance.stub(:new_record?) { true }
        CDN::CommunicationSystem.should_receive(:upload)
        new_photo.save
        expect(new_photo.uuid).to_not be_nil
        expect(new_photo).to be_valid
      end

      it "if uuid has been set, should set another one." do
        Photo.any_instance.stub(:new_record?) { true }
        CDN::CommunicationSystem.should_receive(:upload)
        uuid = photo.uuid
        photo.save
        expect(photo.uuid).to_not eq(uuid)
        expect(photo).to be_valid
      end
    end

    describe "#save" do

      it "saves an image that is new and has been uploaded successfully" do
        Photo.any_instance.stub(:new_record?) { true }

        CDN::CommunicationSystem.should_receive(:upload)
        photo.should_receive(:super_save_is_called)

        photo.save
      end

      it "does not save an image that is new and has not received a response from cdn" do
        Photo.any_instance.stub(:new_record?) { true }
        CDN::CommunicationSystem.stub(:upload).and_raise(Exceptions::CdnResponseException.new("http_response was nil"))

        CDN::CommunicationSystem.should_receive(:upload)
        photo.should_not_receive(:super_save_is_called)

        photo.save
      end

      it "does not save an image that is new and has not been uploaded successfully for unknown reasons" do
        Photo.any_instance.stub(:new_record?) { true }
        CDN::CommunicationSystem.stub(:upload).and_raise(Exceptions::CdnUnknownException.new("cdn communication system failed"))

        CDN::CommunicationSystem.should_receive(:upload)
        photo.should_not_receive(:super_save_is_called)

        photo.save
      end

      it "does not upload a new image that is not a new record and does not have a new uuid" do
        Photo.any_instance.stub(:new_record?) { false }
        Photo.any_instance.stub(:changed) { [] }

        CDN::CommunicationSystem.should_not_receive(:upload)
        photo.should_receive(:super_save_is_called)

        photo.save
      end

      it "uploads the image if its not a new record but has a new uuid" do
        Photo.any_instance.stub(:new_record?) { false }
        Photo.any_instance.stub(:changed) { ["uuid"] }

        CDN::CommunicationSystem.should_receive(:upload)
        photo.should_receive(:super_save_is_called)

        photo.save

      end

    end

    describe "#destroy" do

      it  "deletes an image if it is deleted successfully from the server" do
        Photo.any_instance.stub(:new_record?) { false }
        CDN::CommunicationSystem.stub(:delete) { true }


        CDN::CommunicationSystem.should_receive(:delete)
        photo.should_receive(:super_destroy_is_called)

        photo.destroy
      end

      it "does not delete an image that is a new record" do
        Photo.any_instance.stub(:new_record?) { true }

        CDN::CommunicationSystem.should_not_receive(:delete)
        photo.should_receive(:super_destroy_is_called)

        photo.destroy

      end

      it  "does not delete an image if there is an unknown error from the server" do
        Photo.any_instance.stub(:new_record?) { false }
        CDN::CommunicationSystem.stub(:delete).and_raise(Exceptions::CdnUnknownException.new("cdn communication system failed"))

        CDN::CommunicationSystem.should_receive(:delete)
        photo.should_not_receive(:super_destroy_is_called)

        photo.destroy
      end

      it  "does not delete an image if there no response from the server" do
        Photo.any_instance.stub(:new_record?) { false }
        CDN::CommunicationSystem.stub(:delete).and_raise(Exceptions::CdnResponseException.new("http_response was nil"))

        CDN::CommunicationSystem.should_receive(:delete)
        photo.should_not_receive(:super_destroy_is_called)

        photo.destroy
      end
    end

    describe "#url" do

      it "returns an url to the image with the given uuid" do
        Photo.any_instance.stub(:new_record?) { false }
        CDN::CommunicationSystem.stub(:info)
        CDN::CommunicationSystem.should_receive(:download)
        photo.url
      end

      it "returns nil if image is a new record" do
        Photo.any_instance.stub(:new_record?) { true }
        CDN::CommunicationSystem.stub(:info)
        expect(photo.url).to be_nil
      end

      it "returns nil if the object does not exist" do
        Photo.any_instance.stub(:new_record?) { false }
        CDN::CommunicationSystem.stub(:info).with({ uuid: new_photo.uuid }).and_raise(Exceptions::NotFoundException.new("Does not exist any image with that uuid"))
        expect(new_photo.url).to be_nil
      end
    end

  end
end
