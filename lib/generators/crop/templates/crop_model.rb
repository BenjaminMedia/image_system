class <%= class_name.camelize %>Crop < ActiveRecord::Base
  # Constants
  ASPECT_RATIOS = {
    original: 0,
    square: 1.0/1.0
  }

  # Associations
  belongs_to :<%= class_name %>

  # Attributes
  enum aspect: ASPECT_RATIOS.keys

  # Validations
  validates :y1, presence: true
  validates :x1, presence: true
  validates :y2, presence: true
  validates :x2, presence: true
  validates :<%= class_name %>, presence: true
  validates :aspect, uniqueness: { scope: :<%= class_name %>_id }

  # Class Methods
  def self.aspect_ratios
    raise NotImplementedError, "Must implement a hash of aspects in the following format: { aspect_name: aspect_ratio }"
  end

  def self.available_aspects
    aspects.keys
  end

  def self.crop_for(aspect)
    find_by_aspect(aspects[aspect])
  end

  def self.default_crop(image, aspect)
    if aspect.nil? || aspect.to_sym == :original
      nil
    else
      new_dimensions = calculate_dimensions(image.width, image.height, aspect_ratios[aspect])
      crop = calculate_crop(image.width, image.height, new_dimensions[:width], new_dimensions[:height])

      new crop.merge(aspect: aspect)
    end
  end

private

  def self.calculate_dimensions(width, height, ratio)
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
