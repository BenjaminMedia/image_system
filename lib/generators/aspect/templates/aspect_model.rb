class Aspect < ActiveRecord::Base

  # Associations
  has_many :crops

  # Validations
  validates :name, presence: true
  validates :aspect_ratio, presence: true
end
