FactoryGirl.define do
  factory :photo do
    source_file { ActionDispatch::Http::UploadedFile.new(tempfile: File.new("#{Rails.root}/public/images/test_image.jpg"), filename: "test_image.jpg", type: "image/jpg") }
  end
end
