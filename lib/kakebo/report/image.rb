require 'rmagick'

class Kakebo::Report::Image
  module Just
    refine String do
      def mb_rjust(width, padding = ' ')
        rjust(width - mb_count, padding) 
      end

      def mb_center(width, padding = ' ')
        center(width - mb_count, padding) 
      end

      def mb_width
        each_char.map { |c| [c.bytesize, 2].min }.inject(&:+)
      end

      def mb_count
        each_char.count { |c| c.bytesize > 1 }
      end
    end
  end
  
  using Just

  def self.daily_summary(base_date)
    new.daily_summary(base_date)
  end

  def daily_summary(base_date)
    values = {
      daily:   Kakebo::Item.daily_summary(base_date),
      weekly:  Kakebo::Item.weekly_summary(base_date),
      monthly: Kakebo::Item.monthly_summary(base_date)
    }
    text = formatted_text(values)
    path = Dir.tmpdir + '/kakebo_summary_' + [*'a'..'z'].sample(8).join + '.png'
    generate_image(text, path)
    path
  end

  private

  def formatted_text(values)
    categories  = ['必要経費', '浪費', '固定費', '投資', '特別費', '計']
    title_width = categories.map { |c| c.mb_width }.max
    cell_width  = 9 # < 1,000,000

    header = ([' ' * title_width] + ['今日', '今週', '今月'].map { |c| c.mb_center(cell_width) }).join(' | ') + ' |'
    hbar = '-' * header.mb_width
    contents = categories.map do |c|
      [
        c.mb_rjust(title_width),
        values[:daily  ][c].to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,').rjust(cell_width),
        values[:weekly ][c].to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,').rjust(cell_width),
        values[:monthly][c].to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,').rjust(cell_width),
      ].join(' | ') + ' |'
    end

    ([header, hbar] + contents).map { |row| ' ' + row }.join("\n")
  end

  def generate_image(text, path)
    blankImg = Magick::Image.new(720, 290)
    draw = Magick::Draw.new
    draw.annotate(blankImg, 0, 0, 0, 40, text) do
      self.fill = "black"
      self.pointsize = 30
      self.font = '/home/naoyoshi/Ricty-Regular.ttf' # TODO:
    end
    blankImg.write(path)
  end
end
