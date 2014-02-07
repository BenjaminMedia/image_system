class <%= class_name.camelize %>Aspect < ActiveRecord::Base

  # Associations
  has_many :<%= class_name %>_crops

  # Validations
  validates :name, presence: true
  validates :aspect_ratio, presence: true
end
