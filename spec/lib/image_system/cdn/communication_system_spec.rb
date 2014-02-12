require 'spec_helper'
require 'uuidtools'
require 'cdnconnect_api'

describe ImageSystem::CDN::CommunicationSystem do

  subject { ImageSystem::CDN::CommunicationSystem }

  before(:all) do
    VCR.use_cassette('image_system/cdn/communication_system/before_all', match_requests_on: [:method, :uri_ignoring_trailing_nonce]) do

      @uuid = "1"
      initialize_api

      @cdn.upload(source_file_path: uploaded_file(:jpg_args).path,
                  destination_file_name: "#{@uuid}.jpg",
                  queue_processing: false,
                  destination_path: '/')

      @already_existing_uuid = 'rename_test_already_exists_exception'

      @cdn.upload(source_file_path: uploaded_file(:jpg_args).path,
                  destination_file_name: "#{@already_existing_uuid}.jpg",
                  queue_processing: false,
                  destination_path: '/')
    end
  end

  after(:all) do
    VCR.use_cassette('image_system/cdn/communication_system/after_all', match_requests_on: [:method, :uri_ignoring_trailing_nonce]) do
      @cdn.delete(uuid: @uuid)
      @cdn.delete(uuid: @already_existing_uuid)
    end
  end

  describe ".upload" do
    before(:all) do
      @jpg_file = uploaded_file(:jpg_args)
      @uuid_to_upload = UUIDTools::UUID.random_create.to_s.gsub(/\-/, '')
    end

    it "returns an error message if file_type is nil" do
      expect { subject.upload( uuid: @uuid_to_upload, source_file_path: @jpg_file.path) }.
        to raise_error(ArgumentError, "File extension is not set")
    end

    it "returns an error message if uuid is nil" do
      expect { subject.upload( uuid: nil, source_file_path: @jpg_file.path, file_extension: @jpg_file.content_type) }.
        to raise_error(ArgumentError, "uuid is not set")
    end

    it "returns an error message if source_file_path is not set" do
      expect { subject.upload( uuid: @uuid_to_upload, source_file_path: nil, file_extension: @jpg_file.content_type) }.
        to raise_error(ArgumentError, "source file(s) required")
    end

    it "returns an error message for missing uuid if no arguments are set" do
      expect { subject.upload }.to raise_error(ArgumentError, "uuid is not set")
    end

    it "returns an error message if the upload fails from cdn" do
      CDNConnect::APIClient.any_instance.stub(:upload) { Response.new(:status => 503) }

      expect { subject.upload( uuid: @uuid_to_upload, source_file_path: @jpg_file.path, file_extension: file_extension(@jpg_file.content_type)) }.
        to raise_error(Exceptions::CdnResponseException, "http_response was nil")
    end

    it "receives a jpg file and uploads it to cdn", :vcr, match_requests_on: [:method, :uri_ignoring_trailing_nonce] do
      res = subject.upload(uuid: @uuid_to_upload, source_file_path: @jpg_file.path, file_extension: file_extension(@jpg_file.content_type))
      expect(res).to eq({result: true, width: 998, height: 1500})
    end

    it "receives a jpeg file and uploads it to cdn", :vcr, match_requests_on: [:method, :uri_ignoring_trailing_nonce] do
      file = uploaded_file(:jpeg_args)
      res = subject.upload(uuid: @uuid_to_upload, source_file_path: file.path, file_extension: file_extension(file.content_type))
      expect(res).to eq({result: true, width: 400, height: 316})
    end

    it "receives a gif file and uploads it to cdn", :vcr, match_requests_on: [:method, :uri_ignoring_trailing_nonce] do
      file = uploaded_file(:gif_args)
      res = subject.upload(uuid: @uuid_to_upload, source_file_path: file.path, file_extension: file_extension(file.content_type))
      expect(res).to eq({result: true, width: 330, height: 263})
    end

     it "receives a png file and uploads it to cdn", :vcr, match_requests_on: [:method, :uri_ignoring_trailing_nonce] do
      file = uploaded_file(:png_args)
      res = subject.upload(uuid: @uuid_to_upload, source_file_path: file.path, file_extension: file_extension(file.content_type))
      expect(res).to eq({result: true, width: 50, height: 64})
    end

  end

  describe ".download" do

    it "returns a string with the link to an image given it's uuid" do
      res = subject.download(uuid: @uuid, file_extension: "png")
      expect(res).to include("#{@uuid}.png")
    end

    it "returns an error message if uuid is nil" do
      expect { subject.download(uuid: nil, file_extension: "jpg") }.to raise_error(ArgumentError, "uuid is not set")
    end

    it "returns an error message if uuid is nil" do
      expect { subject.download(uuid: @uuid, file_extension: nil) }.to raise_error(ArgumentError, "File extension is not set")
    end

    it "returns an error message if no arguments are given" do
      expect { subject.download() }.to raise_error(ArgumentError, "uuid is not set")
    end

    it "returns an image of a certain width if specified" do
      res = subject.download(uuid: @uuid, file_extension: "jpg", width: 100)
      expect(res).to include("width=100")
    end

    it "returns an image of a certain height if specified" do
      res = subject.download(uuid: @uuid, file_extension: "jpg", height: 50)
      expect(res).to include("height=50")
    end

    it "returns an image of a certain height and width if both are specified" do
      res = subject.download(uuid: @uuid, file_extension: "jpg", height: 640, width: 320)
      expect(res).to include("height=640")
      expect(res).to include("width=320")
    end

    it "returns an image with no pre-defined heigth or width is values are set as nil" do
      res = subject.download(uuid: @uuid, file_extension: "jpg", height: nil, width: nil)
      expect(res).to_not include("height")
      expect(res).to_not include("width")
    end

    it "returns an image with a certain quality if set" do
      res = subject.download(uuid: @uuid, file_extension: "jpg", height: 640, width: 320, quality: 10)
      expect(res).to include("quality=10")
    end

    it "returns an image with a quality of 95 if nothing is set" do
      res = subject.download(uuid: @uuid, file_extension: "jpg", height: 640, width: 320)
      expect(res).to include("quality=95")
    end

    it "returns an image with the original aspect" do
      res = subject.download(uuid: @uuid, file_extension: "jpg", aspect: :original)
      expect(res).to include("mode=max")
    end

     it "returns an image with another aspect if not the original one" do
      res = subject.download(uuid: @uuid, file_extension: "jpg", aspect: :square)
      expect(res).to include("mode=crop")
    end

    it "returns an image with the specified cropping coordinates" do
      coordinates = {crop: { x1: 50, y1: 70, x2: 350, y2: 450 } }
      args = { uuid: @uuid, file_extension: "jpg" }.merge(coordinates)
      res = subject.download(args)
      expect(res).to include("50,70,350,450".to_query(:crop))
    end

    it "fails if the passed cropping options does not have the 4 coordinates" do
      coordinates = {crop: { x1: 50, y1: 70, x2: 350 } }
      args = { uuid: @uuid, file_extension: "jpg" }.merge(coordinates)
      expect { subject.download(args) }.to raise_error(Exceptions::WrongCroppingFormatException,
       "Wrong cropping coordinates format. The crop coordinates should be given in the following format { crop: { x1: value, y1: value, x2: value, y2: value } } ")
    end

    it "fails if the passed cropping options have one repeated coordinate" do
      coordinates = {crop: { x1: 50, y2: 70, x2: 350, y2: 450 } }
      args = { uuid: @uuid, file_extension: "jpg" }.merge(coordinates)
      expect { subject.download(args) }.to raise_error(Exceptions::WrongCroppingFormatException,
       "Wrong cropping coordinates format. The crop coordinates should be given in the following format { crop: { x1: value, y1: value, x2: value, y2: value } } ")
    end

    it "returns an image with the specified cropping coordinates even thought they are not in the same order" do
      coordinates = {crop: { x1: 50, y2: 70, x2: 350, y1: 450 } }
      args = { uuid: @uuid, file_extension: "jpg" }.merge(coordinates)
      res = subject.download(args)
      expect(res).to include("50,450,350,70".to_query(:crop))
    end

    it "returns a url without cropping if there is no crop coordinates" do
      args = { uuid: @uuid, file_extension: "jpg" }
      res = subject.download(args)
      expect(res).to_not include("crop")
    end
  end

  describe ".rename" do
    before(:all) do
      VCR.use_cassette('image_system/cdn/communication_system_rename/before_all', :match_requests_on => [:method, :uri_ignoring_trailing_nonce]) do
        @old_uuid = "1"
        @new_uuid = "new_uuid"
        @cdn.delete_object(path: "/#{@new_uuid}.jpg")
      end
    end

    after(:each) do
      VCR.use_cassette('image_system/cdn/communication_system_rename/after_each', :match_requests_on => [:method, :uri_ignoring_trailing_nonce]) do
        @cdn.rename_object(path: "/#{@new_uuid}.jpg", new_name: "#{@old_uuid}.jpg")
      end
    end

    it "returns true when renaming an object is successful", :vcr do
      res = subject.rename(old_uuid: @old_uuid, new_uuid: @new_uuid, file_extension: "jpg")
      expect(res).to eq(true)
    end

    it "returns an exception if an object is not found", :vcr do
      expect { subject.rename( old_uuid: "2", new_uuid: @new_uuid, file_extension: "jpg") }.
        to raise_error(Exceptions::NotFoundException, "Does not exist any image with that uuid")
    end

    it "returns an exception if there is an image with the same uuid as new uuid", :vcr do
      expect { subject.rename( old_uuid: @old_uuid, new_uuid: @already_existing_uuid, file_extension: "jpg") }.
        to raise_error(Exceptions::AlreadyExistsException, "There is an image with the same uuid as the new one")
    end

    it "returns an error if the old uuid is not provided" do
      expect { subject.rename( new_uuid: @already_existing_uuid, file_extension: "jpg") }.to raise_error(ArgumentError,"old uuid is not set")
    end

    it "returns an error if the new uuid is not provided" do
      expect { subject.rename( old_uuid: @old_uuid, file_extension: "jpg" ) }.to raise_error(ArgumentError,"new uuid is not set")
    end

    it "returns an error if the old uuid is the same as the new" do
      expect { subject.rename( old_uuid: @old_uuid, new_uuid: @old_uuid, file_extension: "jpg") }.
        to raise_error(ArgumentError,"old uuid is the same as the new")
    end

    it "returns an error if the old uuid is the same as the new" do
      expect { subject.rename(old_uuid: @old_uuid, new_uuid: @new_uuid) }.
        to raise_error(ArgumentError,"File extension is not set")
    end

    it "returns an error if the renaming fails" do
      CDNConnect::APIClient.any_instance.stub(:rename_object) { Response.new }
      expect { subject.rename( old_uuid: @old_uuid, new_uuid: @new_uuid, file_extension: "jpg") }.
        to raise_error(Exceptions::CdnUnknownException, "cdn communication system failed")
    end
  end

  describe ".delete" do

    it "deletes the picture and returns true if the given uuid exists", :vcr, match_requests_on: [:method, :uri_ignoring_trailing_nonce] do
      res = subject.delete(uuid: @already_existing_uuid, file_extension: "jpg")
      expect(res).to eq(true)

      # Make sure the file does not disappear for other tests
      @cdn.upload( source_file_path: uploaded_file(:jpg_args).path,
                   destination_file_name: "#{@already_existing_uuid}.jpg",
                   queue_processing: false,
                   destination_path: '/')
    end

    it "does not delete if it does exist and returns an error", :vcr do
      expect { subject.delete(uuid: "non_existing_uuid", file_extension: "jpg") }.
        to raise_error(Exceptions::NotFoundException, "Does not exist any image with that uuid")
    end

    it "does not delete if it does exist and returns an error", :vcr do
      expect { subject.delete(uuid: @already_existing_uuid) }.
        to raise_error(ArgumentError, "File extension is not set")
    end

    it "does not delete if no uuid is given and returns an error" do
      expect { subject.delete() }.to raise_error(ArgumentError, "uuid is not set")
    end

    it "returns an error if the deleting operation fails" do
      CDNConnect::APIClient.any_instance.stub(:delete_object) { Response.new }
      expect { subject.delete(uuid: "non_existing_uuid", file_extension: "jpg") }.
        to raise_error(Exceptions::CdnUnknownException, "cdn communication system failed")
    end

  end

  describe ".info" do

    it "returns true if the image exists for that uuid", :vcr do
      res = subject.info(uuid: @uuid, file_extension: "jpg")
      expect(res).to eq(true)
    end

    it "returns an error if no uuid is given" do
      expect { res = subject.info() }.to raise_error(ArgumentError, "uuid is not set")
    end

    it "returns an error if no uuid is given" do
      expect { res = subject.info(uuid: @uuid) }.to raise_error(ArgumentError, "File extension is not set")
    end

    it "returns an error if the image for that uuid does not exist", :vcr do
      expect { res = subject.info(uuid: "non_existing_uuid", file_extension: "jpg") }.
        to raise_error(Exceptions::NotFoundException, "Does not exist any image with that uuid")
    end

  end

end

