require 'twitter'

class Kakebo::DataSource::Twitter
  def initialize(config)
    @stream = Twitter::Streaming::Client.new(config)
  end

  def run
    @stream.user do |object|
      if object.class == Twitter::Tweet
        process_tweet(object.text)
      end
    end
  end

  def process_tweet(text)
    md = text.strip.match(/^([^\s]*)\s(\d*)円$/)
    return unless md
    title, value = md[1], md[2].to_i
    category = Kakebo::Category.find_by_name('食費').id # TODO
    Kakebo::Item.create(title: title, value: value, category: category, date: Date.today)
  end
end
