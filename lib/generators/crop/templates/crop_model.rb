class Crop < ActiveRecord::Base

  # Associations
  belongs_to :<%= class_name %>
  belongs_to :aspect

  # Validations
  validates :y1, presence: true
  validates :x1, presence: true
  validates :y2, presence: true
  validates :x2, presence: true
  validates :picture, presence: true
  validates :aspect, presence: true
  validates :aspect, uniqueness: { scope: :picture }
end
