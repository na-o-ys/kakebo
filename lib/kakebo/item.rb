class Kakebo::Item
  include Kakebo::Storage::SpreadSheet
  spreadsheet_key Kakebo::Config['spreadsheet_key']
  define_columns :title, :value, :category, :date

  def self.find_by_date(date)
    find_by(date_to_sheet_name(date), date: date)
  end

  def self.date_to_sheet_name(date)
    Date.parse(date.to_s).strftime('%Y-%m')
  end

  def sheet_name
    Kakebo::Item.date_to_sheet_name(date)
  end
end
