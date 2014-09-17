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
    ASPECT_RATIOS.with_indifferent_access
  end

  def self.available_aspects
    aspects.keys
  end

  def self.crop_for(aspect)
    find_by_aspect(aspects[aspect])
  end

  def self.default_crop(image, aspect)
    if aspect.to_sym == :original
      nil
    else
      new_dimensions = calculate_dimensions(image.width, image.height, aspect_ratios[aspect])
      crop = calculate_crop(image.width, image.height, new_dimensions[:width], new_dimensions[:height])

      new crop.merge(aspect: aspect)
    end
  end

private

  def self.calculate_dimensions(width, height, ratio)
    # raise "#{height} - #{width} - #{ratio}"
    if height * ratio > width
       max_width = width
       max_height = width / ratio
    else
      max_width = height * ratio
      max_height = height
    end

    { width: max_width, height: max_height }
  end

  def self.calculate_crop(orig_width, orig_height, new_width, new_height)
    width_offset = (orig_width - new_width) / 2
    height_offset = (orig_height - new_height) / 2

    {
      x1: width_offset,
      x2: orig_width - width_offset,
      y1: height_offset,
      y2: orig_height - height_offset
    }
  end
end
