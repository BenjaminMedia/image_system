FactoryGirl.define do
  factory :photo_crop do
    photo :photo
    photo_aspect :photo_aspect
    y1 0
    x1 0
    y2 100
    x2 100
  end
end
