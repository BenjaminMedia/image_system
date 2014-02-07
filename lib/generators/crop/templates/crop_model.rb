class <%= class_name.camelize %>Crop < ActiveRecord::Base

  # Associations
  belongs_to :<%= class_name %>
  belongs_to :<%= class_name %>_aspect

  # Validations
  validates :y1, presence: true
  validates :x1, presence: true
  validates :y2, presence: true
  validates :x2, presence: true
  validates :<%= class_name %>, presence: true
  validates :<%= class_name %>_aspect, presence: true
  validates :<%= class_name %>_aspect, uniqueness: { scope: :<%= class_name %> }
end
