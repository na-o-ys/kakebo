module Kakebo
  def self.app_root
    File.expand_path('../../', __FILE__)
  end
end

$:.unshift(Kakebo.app_root + '/lib')
require 'kakebo/config'
require 'kakebo/storage'
require 'kakebo/item'
require 'kakebo/category'
require 'kakebo/data_source'
require 'kakebo/report'
