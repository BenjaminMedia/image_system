FactoryGirl.define do
  factory :photo do
    source_file_path :source_file_path
    height :height
    width :width
    file_extension :file_extension
  end
end
