module Kakebo
  def self.app_root
    File.expand_path('../../', __FILE__)
  end
end

$:.unshift(Kakebo.app_root + '/lib')
require 'kakebo/config.rb'
require 'kakebo/storage.rb'
require 'kakebo/item.rb'
require 'kakebo/category.rb'
require 'kakebo/data_source.rb'
