require 'twitter'
require 'yaml'
require_relative 'storage.rb'

cnf = YAML.load_file('config.yml')
@client = Twitter::REST::Client.new(cnf)
@storage = Storage.new

@client.update("今日は #{@storage.daily_total} 円、今週は #{@storage.weekly_total} 円、今月は #{@storage.monthly_total} 円使った")
