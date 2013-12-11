# encoding: utf-8
require 'spec_helper'
require 'uuidtools'

module ImageSystem
  describe "Image" do

    describe "#save" do

      it "saves an image that is new and has been uploaded successfully" do
        Photo.any_instance.stub(:new_record?) { true }

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''), path: "#{Rails.root}/public/images/test_image.jpg")

        CDN::CommunicationSystem.should_receive(:upload)
        p.should_receive(:super_save_is_called)

        p.save
      end

      it "does not save an image that is new and has not received a response from cdn" do
        Photo.any_instance.stub(:new_record?) { true }
        CDN::CommunicationSystem.stub(:upload).and_raise(Exceptions::CdnResponseException.new("http_response was nil"))

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''), path: "#{Rails.root}/public/images/test_image.jpg")

        CDN::CommunicationSystem.should_receive(:upload)
        p.should_not_receive(:super_save_is_called)

        p.save
      end

      it "does not save an image that is new and has not been uploaded successfully for unknown reasons" do
        Photo.any_instance.stub(:new_record?) { true }
        CDN::CommunicationSystem.stub(:upload).and_raise(Exceptions::CdnUnknownException.new("cdn communication system failed"))

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''), path: "#{Rails.root}/public/images/test_image.jpg")

        CDN::CommunicationSystem.should_receive(:upload)
        p.should_not_receive(:super_save_is_called)

        p.save
      end

      it "does not upload a new image that is not a new record and does not have a new uuid" do
        Photo.any_instance.stub(:new_record?) { false }
        Photo.any_instance.stub(:changed) { [] }

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''), path: "#{Rails.root}/public/images/test_image.jpg")

        CDN::CommunicationSystem.should_not_receive(:upload)
        p.should_receive(:super_save_is_called)

        p.save
      end

      it "uploads the image if its not a new record but has a new uuid" do
        Photo.any_instance.stub(:new_record?) { false }
        Photo.any_instance.stub(:changed) { ["uuid"] }

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''), path: "#{Rails.root}/public/images/test_image.jpg")

        CDN::CommunicationSystem.should_receive(:upload)
        p.should_receive(:super_save_is_called)

        p.save

      end

    end

    describe "#destroy" do

      it  "deletes an image if it is deleted successfully from the server" do
        Photo.any_instance.stub(:new_record?) { false }
        CDN::CommunicationSystem.stub(:delete) { true }

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''))

        CDN::CommunicationSystem.should_receive(:delete)
        p.should_receive(:super_destroy_is_called)

        p.destroy
      end

      it "does not delete an image that is a new record" do
        Photo.any_instance.stub(:new_record?) { true }

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''))

        CDN::CommunicationSystem.should_not_receive(:delete)
        p.should_receive(:super_destroy_is_called)

        p.destroy

      end

      it  "does not delete an image if there is an unknown error from the server" do
        Photo.any_instance.stub(:new_record?) { false }
        CDN::CommunicationSystem.stub(:delete).and_raise(Exceptions::CdnUnknownException.new("cdn communication system failed"))

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''))

        CDN::CommunicationSystem.should_receive(:delete)
        p.should_not_receive(:super_destroy_is_called)

        p.destroy
      end

      it  "does not delete an image if there no response from the server" do
        Photo.any_instance.stub(:new_record?) { false }
        CDN::CommunicationSystem.stub(:delete).and_raise(Exceptions::CdnResponseException.new("http_response was nil"))

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''))

        CDN::CommunicationSystem.should_receive(:delete)
        p.should_not_receive(:super_destroy_is_called)

        p.destroy
      end
    end

    describe "#url" do

      it "returns an url to the image with the given uuid" do

        Photo.any_instance.stub(:new_record?) { false }

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''))
        CDN::CommunicationSystem.should_receive(:download)

        p.url
      end

      it "returns an url to the image with the given uuid" do
        Photo.any_instance.stub(:new_record?) { true }

        p = Photo.new(uuid: UUIDTools::UUID.random_create.to_s.gsub(/\-/, ''))
        CDN::CommunicationSystem.should_not_receive(:download)

        p.url
      end
    end

  end
end
