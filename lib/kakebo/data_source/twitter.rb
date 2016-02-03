require 'twitter'

class Kakebo::DataSource::Twitter
  def initialize(config)
    @config = config
    resume_stream
  end

  def run
    @stream.user do |object|
      if object.class == Twitter::Tweet
        process_tweet(object.text)
      end
    end
  rescue EOFError
    resume_stream
    retry
  end

  def resume_stream
    @stream = Twitter::Streaming::Client.new(@config)
  end

  def process_tweet(text)
    return unless text.strip.match(/^.*\s\d+円$/)
    elems = text.strip.split
    return unless [2, 3].include? elems.size
    value         = elems[-1][/(\d+)円/, 1]
    title         = elems[-2]
    category_name = elems[-3]
    categories    = Kakebo::Category.all
    category      = categories.find { |c| c.name == category_name }
    category    ||= categories.find { |c| c.name == '必要経費' }
    Kakebo::Item.create(
      title:    title,
      value:    value,
      category: category.id,
      date:     Date.today
    )
  end
end
