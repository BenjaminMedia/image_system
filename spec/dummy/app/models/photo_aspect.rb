class PhotoAspect < ActiveRecord::Base

  # Associations
  has_many :photo_crops

  # Validations
  validates :name, presence: true
  validates :aspect_ratio, presence: true
end
