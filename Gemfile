source "https://rubygems.org"

#specificy your dependencies in image_system.gemspec
gemspec

group :development, :test do

  # Use guard for automated testing
  gem "guard-rspec", require: false

  # Detects file changes in Mac OS X
  gem "rb-fsevent", require: false

  # Use debugger
  gem "debugger"

  # Speed up common command line tasks with Zeus
  gem "zeus", require: false
end

group :test do

  # Adding code coverage support with code climate
  gem "codeclimate-test-reporter", require: false

end
