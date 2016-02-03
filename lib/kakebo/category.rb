class Kakebo::Category
  include Kakebo::Storage::SpreadSheet
  spreadsheet_key Kakebo::Config['spreadsheet_key']
  define_columns :name

  def self.find_by_name(name)
    find_by('categories', name: name).first
  end

  def self.all
    super('categories')
  end

  def sheet_name
    'categories'
  end
end
