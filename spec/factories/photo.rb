FactoryGirl.define do
  factory :photo do
    source_file :source_file
    height :height
    width :width
    file_extension :file_extension
  end
end
