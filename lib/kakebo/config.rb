require 'yaml'
require 'forwardable'

class Kakebo::Config
  @yml = YAML.load_file(Kakebo.app_root + '/config/config.yml')

  def self.[](key)
    @yml[key]
  end
end
