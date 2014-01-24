class Photo < ActiveRecord::Base
  include ImageSystem::Concerns::Image

end
