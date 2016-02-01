require 'twitter'
require 'yaml'
require_relative 'storage.rb'

cnf = YAML.load_file('config.yml')
@s_client = Twitter::Streaming::Client.new(cnf)
@client = Twitter::REST::Client.new(cnf)
@storage = Storage.new

def process_tweet(tweet)
  md = tweet.text.strip.match(/^([^\s]*)\s(\d*)円$/)
  return false unless md
  name, value = md[1], md[2].to_i
  @storage.add_kakebo(name, value)
  return true
end

def notify_daily
  @client.update("今日は #{@storage.daily_total} 円使った " + '#家計簿')
end

loop do
  begin
    @s_client.user do |object|
      if object.class == Twitter::Tweet and process_tweet(object)
        notify_daily
      end
    end
  rescue
    retry
  end
end
