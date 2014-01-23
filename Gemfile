source "https://rubygems.org"

#specificy your dependencies in image_system.gemspec
gemspec

group :development, :test do

  # this a rails only gem
  gem "activesupport"

  # Use guard for automated testing
  gem "guard-rspec", require: false

  # Detects file changes in Mac OS X
  gem "rb-fsevent", require: false

  # Use debugger
  gem "debugger"
end

group :test do
  # Adding code coverage support with code climate
  gem "codeclimate-test-reporter", require: false
end
