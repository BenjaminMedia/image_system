$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "image_system/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "image_system"
  s.version     = ImageSystem::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = ["Bonnier Publications - Interactive"]
  s.email       = ["feedback@benjamin.dk"]
  s.homepage    = "https://github.com/BenjaminMedia/WhiteAlbum"
  s.summary     = "Image system for rails apps"
  s.description = "It implements the functionalities a image system should have"

  s.rubyforge_project = "image_system"

  s.files      = Dir["{app,config,db,lib}/**/*", "Rakefile"]
  s.test_files = Dir["spec/**/*"]
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # allows to communicate with the cdn image system API
  s.add_dependency "cdnconnect-api",'~> 0.4.2'

  # allows the creation of long ids for the images
  s.add_dependency "uuidtools",'~> 2.1.4'

  # rails interface to databases, allows to use validations and callbacks
  s.add_dependency "activerecord",'~> 4.0.4'

  # adds methods to test generators with rspec
  s.add_development_dependency "generator_spec"

  # testing framework
  s.add_development_dependency "rspec"

  # records webservice calls, making tests faster.
  s.add_development_dependency "vcr"

  # vcr depends on it to record the calls and block calls that do not use vcr
  s.add_development_dependency "webmock",'~> 1.15.2'

  # the dummie app needs a database configuration.
  s.add_development_dependency "sqlite3"
end
