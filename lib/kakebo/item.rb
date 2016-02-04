module Kakebo
  class Item
    include Storage::SpreadSheet
    spreadsheet_key Config['spreadsheet_key']
    define_columns :title, :value, :category, :date

    def self.find_by_date(date)
      find_by(date_to_sheet_name(date), date: date)
    end

    def self.date_to_sheet_name(date)
      Date.parse(date.to_s).strftime('%Y-%m')
    end

    def sheet_name
      Item.date_to_sheet_name(date)
    end

    # TODO: module化
    def self.daily_summary(date)
      summary(find_by_date(date))
    end

    def self.weekly_summary(date)
      start = date - (date.wday - 1) % 7
      range = (start..date)
      sheet_names = [
        date_to_sheet_name(start),
        date_to_sheet_name(date)
      ].uniq

      items = sheet_names.map do |name|
        find(name) { |i| range.include? Date.parse(i.date) }
      end.flatten

      summary(items)
    end

    def self.monthly_summary(date)
      start = date - date.mday + 1
      range = (start..date)
      sheet_name = date_to_sheet_name(date)

      items = find(sheet_name) { |i| range.include? Date.parse(i.date) }
      summary(items)
    end

    def self.summary(items)
      cats = Category.all.map { |c| [c.id, c.name] }.to_h
      items.group_by(&:category)
        .map { |c, is| [cats[c], is.map { |i| i.value.to_i }.inject(&:+)] }
        .to_h
        .tap { |h|
          h['計'] = h.map(&:last).inject(&:+)
          h.default = 0
        }
    end
  end
end
