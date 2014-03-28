class PhotoCrop < ActiveRecord::Base

  # Associations
  belongs_to :photo
  belongs_to :photo_aspect

  # Validations
  validates :y1, presence: true
  validates :x1, presence: true
  validates :y2, presence: true
  validates :x2, presence: true
  validates :photo, presence: true
  validates :photo_aspect, presence: true
  validates :photo_aspect, uniqueness: { scope: :photo }
end
