require 'redis'
require 'forwardable'
require 'date'
require 'json'

class Storage
  extend Forwardable

  def initialize
    @redis = Redis.new
  end

  def_delegators :@redis, :set, :get

  def daily(date)
    JSON.load(get(date.to_s)) || []
  end

  def add_kakebo(name, value)
    key = Date.today.to_s
    data = daily(key) + [[name, value]]
    set(key, data.to_json)
  end

  def daily_total
    daily(Date.today).map(&:last).inject(&:+)
  end

  def monthly_total
  end
end
