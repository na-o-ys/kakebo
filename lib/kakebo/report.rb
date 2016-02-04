class Kakebo::Report
  def initialize(config)
    @twitter = Twitter::REST::Client.new(config)
  end

  def report
    path = Image.daily_summary(Date.today)
    open(path) do |f|
      @twitter.update_with_media(text, f)
    end
    File.delete(path)
  end

  def text
    "@na_o_ys 本日のサマリーだよ #家計簿"
  end
end

require 'kakebo/report/image'
