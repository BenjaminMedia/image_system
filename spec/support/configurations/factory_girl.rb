require 'factory_girl'

FactoryGirl.definition_file_paths << Pathname.new(File.expand_path("../../factories", __FILE__))
FactoryGirl.find_definitions

FactoryGirl.define do
  sequence(:random_string)      { Faker::Lorem.sentence }
  sequence(:random_description) { Faker::Lorem.paragraphs(1 + Kernel.rand(5)).join("\n") }
  sequence(:random_email)       { Faker::Internet.email }
end

RSpec.configure do |config|
  # Include factory girl syntax methods so you can write create(:article), or build(:profile)
  config.include FactoryGirl::Syntax::Methods
end
