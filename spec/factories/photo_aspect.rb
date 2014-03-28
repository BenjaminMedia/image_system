FactoryGirl.define do
  factory :photo_aspect do
    name "original"
    aspect_ratio 1
  end

  factory :square_photo_aspect, parent: :photo_aspect do
    name "square"
    aspect_ratio 1/2
  end

  factory :tv_photo_aspect, parent: :photo_aspect do
    name "tv"
    aspect_ratio 9.0/13.0
  end
end
