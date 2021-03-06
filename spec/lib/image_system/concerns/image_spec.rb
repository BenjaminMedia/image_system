require 'spec_helper'

describe ImageSystem::Concerns::Image do
  let(:new_photo) { build(:photo) }
  let(:photo) { create(:photo) }

  describe "#validations" do

    before(:each) do
      ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
    end

    context "has source file" do
      it "is valid" do
        expect(new_photo).to be_valid
      end

      describe "check_source_file_content_type" do
        it "does not validate an object which the content_type is not allowed" do
          bmp_photo = build(:photo, source_file: uploaded_file(:bmp_args))
          expect(bmp_photo).to_not be_valid
        end

        it "validates jpg files" do
          jpg_photo = build(:photo, source_file: uploaded_file(:jpg_args))
          expect(jpg_photo).to be_valid
        end

        it "validates jpeg files" do
          jpeg_photo = build(:photo, source_file: uploaded_file(:jpeg_args))
          expect(jpeg_photo).to be_valid
        end

        it "validates png files" do
          png_photo = build(:photo, source_file: uploaded_file(:png_args))
          expect(png_photo).to be_valid
        end

        it "validates gif files" do
          gif_photo = build(:photo, source_file: uploaded_file(:gif_args))
          expect(gif_photo).to be_valid
        end

        it "white list can be extended" do
          bmp_photo = build(:photo, source_file: uploaded_file(:bmp_args))
          Photo.any_instance.stub(:extension_to_content_type_white_list).and_return(%w(image/bmp))
          expect(bmp_photo).to be_valid
        end
      end
    end

    context "has no source file" do
      let(:new_photo) { build(:photo, source_file: nil) }

      it "validates the presence of width" do
        expect(new_photo).to_not be_valid
        expect(new_photo.errors[:width]).to include("can't be blank")
      end

      it "validates the presence of height" do
        expect(new_photo).to_not be_valid
        expect(new_photo.errors[:height]).to include("can't be blank")
      end

      it "validates the presence of file extension" do
        expect(new_photo).to_not be_valid
        expect(new_photo.errors[:file_extension]).to include("can't be blank")
      end
    end
  end

  describe "before_create" do
    describe "#set_uuid" do
      before(:each) do
        ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
      end

      it "sets uuid if is not set" do
        expect(new_photo.uuid).to be_nil
        new_photo.save
        expect(new_photo.uuid).to_not be_nil
      end
    end

    describe "#upload_to_system" do
      it "does not save an image that is new and has not received a response from cdn" do
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload).and_raise(ImageSystem::Exceptions::CdnResponseException.new("http_response was nil"))
        expect(new_photo.save).to eq(false)
        expect(new_photo.errors.full_messages).to include("The photo could not be uploaded")
      end

      it "does not save an image that is new and has not been uploaded successfully for unknown reasons" do
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload).and_raise(ImageSystem::Exceptions::CdnUnknownException.new("cdn communication system failed"))
        expect(new_photo.save).to eq(false)
        expect(new_photo.errors.full_messages).to include("The photo could not be uploaded")
      end

      it "saves an image that is new and has been uploaded successfully" do
        new_photo.stub(:uuid).and_return("1")
        upload_args = { uuid: new_photo.uuid, source_file_path: new_photo.source_file.path, file_extension: "jpg"}
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload).with(upload_args).and_return({result: true , height: 100, width: 100})
        expect(new_photo.save).to eq(true)
      end

      it "does not upload a new image that is not a new record and does not have a new uuid" do
        ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
        expect(photo).to_not be_a_new_record

        ImageSystem::CDN::CommunicationSystem.should_not_receive(:upload)
        expect(photo.save).to eq(true)
      end

      it "sets the height and width if upload is correct" do
        expect(new_photo.height).to be_nil
        expect(new_photo.width).to be_nil
        ImageSystem::CDN::CommunicationSystem.should_receive(:upload).and_return({result: true , height: 100, width: 200})
        new_photo.save
        expect(new_photo.height).to eq(100)
        expect(new_photo.width).to eq(200)
      end
    end

    describe "#set_file_extension" do
      before(:each) do
        ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
      end

      it "sets the file_extension " do
        expect(new_photo.file_extension).to be_nil
        new_photo.save
        expect(new_photo.file_extension).to_not be_nil
      end
    end
  end

  describe "#destroy" do
    before(:each) do
      ImageSystem::CDN::CommunicationSystem.stub(:upload).and_return({result: true , height: 100, width: 100})
    end

    it  "deletes an image if it is deleted successfully from the server" do
      ImageSystem::CDN::CommunicationSystem.stub(:delete) { true }
      ImageSystem::CDN::CommunicationSystem.should_receive(:delete).with({ uuid: photo.uuid, file_extension: "jpg" })
      expect(photo.destroy).to eq(photo)
    end

    it "does not delete an image that is a new record" do
      ImageSystem::CDN::CommunicationSystem.should_not_receive(:delete)
      expect(new_photo.destroy).to eq(new_photo)
    end

    it "does not delete an image if there is an unknown error from the server" do
      ImageSystem::CDN::CommunicationSystem.stub(:delete).and_raise(ImageSystem::Exceptions::CdnUnknownException.new("cdn communication system failed"))
      ImageSystem::CDN::CommunicationSystem.should_receive(:delete)
      expect(photo.destroy).to eq(false)
    end

    it  "does not delete an image if there isn't a response from the server" do
      ImageSystem::CDN::CommunicationSystem.stub(:delete).and_raise(ImageSystem::Exceptions::CdnResponseException.new("http_response was nil"))
      ImageSystem::CDN::CommunicationSystem.should_receive(:delete)
      expect(photo.destroy).to eq(false)
    end

    context "has crops" do
      let(:photo_crop) { create(:photo_crop, photo: photo) }

      it "deletes all crops related to deleted photo" do
        photo.crops = [photo_crop]
        ImageSystem::CDN::CommunicationSystem.stub(:delete) { true }
        expect {
          photo.destroy
        }.to change(photo.crops, :count).to(0)
      end
    end
  end

  describe "#url" do
    before(:each) do
      allow(ImageSystem::CDN::CommunicationSystem).to receive(:upload).and_return({result: true , height: 100, width: 100})
    end

    it "returns nil if image is a new record" do
      expect(ImageSystem::CDN::CommunicationSystem).to_not receive(:info)
      expect(ImageSystem::CDN::CommunicationSystem).to_not receive(:download)
      expect(new_photo.url).to be_nil
    end

    context "the image exists" do
      before(:each) do
        allow(ImageSystem::CDN::CommunicationSystem).to receive(:info).with({ uuid: photo.uuid, file_extension: "jpg" }).and_return(true)
      end

      it "returns an url to the image" do
        download_args = { uuid: photo.uuid, file_extension: "jpg", aspect: :original }
        expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args.except(:aspect))
        photo.url
      end

      it "returns an url to the image with download option to true" do
        download_args = { uuid: photo.uuid, file_extension: "jpg", aspect: :original, download: true }
        expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args.except(:aspect))
        photo.url(download: true)
      end

      it "returns an url to the image with download option to true(string passed)" do
        download_args = { uuid: photo.uuid, file_extension: "jpg", aspect: :original, download: "true" }
        expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args.except(:aspect))
        photo.url(download: "true")
      end

      it "returns an url to the image with the given width and height" do
        download_args = { uuid: photo.uuid, file_extension: "jpg", aspect: :original, width: 80, height: 50 }
        expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args.except(:aspect))
        photo.url(width: 80, height: 50)
      end

      it "returns an url to the image with the given aspect" do
        download_args = { uuid: photo.uuid, file_extension: "jpg", aspect: "square", crop: { x1: 0, y1: 0, x2: 100, y2: 100 } }
        expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args.except(:aspect))
        photo.url(aspect: "square")
      end

      context "crops exists" do
        let(:photo_crop) { create(:photo_crop, photo: photo, aspect: "square") }

        it "returns an url to the image with the given aspect and the crop coordinates" do
          download_args = { uuid: photo.uuid, file_extension: "jpg", aspect: "square",
                            crop: { x1: photo_crop.x1, y1: photo_crop.y1, x2: photo_crop.x2, y2: photo_crop.y2 } }
          expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args.except(:aspect))
          photo.url(aspect: "square")
        end

        it "returns an url to the image with the given aspect and the crop coordinates (aspect name given in symbol)" do
          download_args = { uuid: photo.uuid, file_extension: "jpg", aspect: :square,
                            crop: { x1: photo_crop.x1, y1: photo_crop.y1, x2: photo_crop.x2, y2: photo_crop.y2 } }
          expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args.except(:aspect))
          photo.url(aspect: :square)
        end
      end

      context "crops does not exists" do
        context "image fits in aspect" do
          it "returns an url to the image with full crop coordinates" do
            download_args = { uuid: photo.uuid, file_extension: "jpg", aspect: "square",
                              crop: { x1: 0, y1: 0, x2: photo.width, y2: photo.height } }
            expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args.except(:aspect))
            photo.url(aspect: "square")
          end
        end

        context "image does not fit in aspect" do
          before do
            photo.width = 100
            photo.height = 50
          end

          it "returns an url to the image with centered crop coordinates for the aspect" do
            download_args = { uuid: photo.uuid, file_extension: "jpg", aspect: :square,
                              crop: { x1: 25, y1: 0, x2: 75, y2: 50 } }
            expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args.except(:aspect))
            photo.url(aspect: :square)
          end
        end
      end

      context "aspect is not specified" do
        it "returns an url to the image without crop coordinates" do
          download_args = { uuid: photo.uuid, file_extension: "jpg" }
          expect(ImageSystem::CDN::CommunicationSystem).to receive(:download).with(download_args)
          photo.url()
        end
      end
    end
  end

  describe "#extension_to_content_type_white_list" do
    it "returns an empty array if not override" do
      expect(new_photo.extension_to_content_type_white_list).to be_empty
    end
  end
end
