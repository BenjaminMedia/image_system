class <%= class_name.camelize %>Crop < ActiveRecord::Base
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
end
