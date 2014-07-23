class PhotoCrop < ActiveRecord::Base
  # Constants
  ASPECT_RATIOS = {
    original: 0,
    square: 1.0/1.0,
    tv: 9.0/13.0,
    wide: 12.0/29.0,
    portrait: 3.0/2.0,
    wide169: 9.0/16.0
  }

  # Associations
  belongs_to :photo

  # Attributes
  enum aspect: ASPECT_RATIOS.keys

  # Validations
  validates :y1, presence: true
  validates :x1, presence: true
  validates :y2, presence: true
  validates :x2, presence: true
  validates :photo, presence: true
  validates :aspect, uniqueness: { scope: :photo_id }

  # Class Methods
  def self.aspect_ratios
    ASPECT_RATIOS
  end

  def self.available_aspects
    aspects.keys
  end
end
