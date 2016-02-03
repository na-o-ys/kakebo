require 'date'
require 'json'
require 'google/api_client'
require 'google_drive'

module Kakebo::Storage::SpreadSheet
  def save
    sheet = self.class.agent.find_or_create_sheet(sheet_name)
    self.id = sheet.generate_id
    cols = self.class.columns.map { |c| self.send(c) }
    sheet.create_row(*cols)
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  # TODO: helper
  def self.obj_to_str(obj)
    case obj
    when Date
      obj.strftime('%Y/%m/%d')
    else
      obj.to_s
    end
  end

  module ClassMethods
    def spreadsheet_key(key)
      @agent = Agent.new(key)
    end

    def agent
      @agent
    end

    def define_columns(*args)
      @columns = columns = [:id] + args
      self.class_eval do
        attr_accessor(*columns)
        define_method(:initialize) do |attrs|
          columns.each do |col|
            instance_variable_set(
              "@#{col}",
              Kakebo::Storage::SpreadSheet.obj_to_str(attrs[col])
            )
          end
        end

        def self.create(attrs)
          new(attrs).tap(&:save)
        end
      end
    end

    def columns
      @columns
    end

    def find_by(sheet_name, cond)
      sheet = agent.worksheet_by_title(sheet_name)
      return [] unless sheet
      rows = sheet.rows.select do |row|
        cond.all? do |col, v|
          row[columns.index(col)] == Kakebo::Storage::SpreadSheet.obj_to_str(v)
        end
      end
      rows.map { |row| new_by_row(row) }
    end

    def find(sheet_name, &block)
      sheet = agent.worksheet_by_title(sheet_name)
      return [] unless sheet
      sheet
        .rows
        .map { |r| new_by_row(r) }
        .select { |r| block.call(r) }
    end

    def all(sheet_name)
      sheet = agent.worksheet_by_title(sheet_name)
      return [] unless sheet
      sheet.rows.map { |row| new_by_row(row) }
    end

    def new_by_row(row)
      attrs = columns
        .each_with_index
        .map { |col, i| [col, row[i]] }
        .to_h
      self.new(attrs)
    end
  end
end

class Kakebo::Storage::SpreadSheet::Agent
  def initialize(spreadsheet_key)
    @session = GoogleDrive
      .saved_session(Kakebo.app_root + '/config/google_key.json')
    @spread_sheet = @session.spreadsheet_by_key(spreadsheet_key)
  end

  def add_worksheet(name)
    Kakebo::Storage::SpreadSheet::WorkSheet.new(@spread_sheet.add_worksheet(name))
  end

  def find_or_create_sheet(name)
    sheet = worksheet_by_title(name)
    return sheet if sheet
    add_worksheet(name)
  end

  def worksheet_by_title(name)
    sheet = @spread_sheet.worksheet_by_title(name)
    return nil unless sheet
    Kakebo::Storage::SpreadSheet::WorkSheet.new(sheet)
  end
end

class Kakebo::Storage::SpreadSheet::WorkSheet
  def initialize(worksheet)
    @ws = worksheet
  end

  def create_row(*args)
    row = @ws.num_rows + 1
    args.each_with_index do |arg, i|
      @ws[row, i+1] = arg
    end
    @ws.save
  end

  def generate_id
    (@ws.rows.map(&:first).map(&:to_i).max || 0) + 1
  end

  def method_missing(name, *args)
    @ws.send(name, *args)
  end
end
