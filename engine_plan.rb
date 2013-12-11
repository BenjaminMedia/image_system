require 'zeus/rails'

ROOT_PATH = File.expand_path(Dir.pwd)
ENV_PATH  = File.expand_path('spec/dummy/config/environment',  ROOT_PATH)
BOOT_PATH = File.expand_path('spec/dummy/config/boot',  ROOT_PATH)
APP_PATH  = File.expand_path('spec/dummy/config/application',  ROOT_PATH)
ENGINE_ROOT = File.expand_path(Dir.pwd)
ENGINE_PATH = File.expand_path('lib/image_system/engine', ENGINE_ROOT)

class EnginePlan < Zeus::Rails
  def test
    Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
    super
  end
end

Zeus.plan = EnginePlan.new
