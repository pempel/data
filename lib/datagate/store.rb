require "csv"
require_relative "store/record"

class Store
  attr_reader :records

  def initialize(file_path: "store.csv", file_col_sep: "|")
    @file_path = file_path
    @file_col_sep = file_col_sep
    @records = []
  end

  def import(line)
    row = line.to_s.split(@file_col_sep).unshift(0)
    record = Record.new(*row)
    record_index = @records.find_index { |r| r.primary_key == record.primary_key }
    if record_index
      record.id = @records[record_index].id
      @records[record_index] = record
    else
      record.id = @records.count + 1
      @records << record
    end
  end

  def load
    if File.exists?(@file_path) && @records.empty?
      CSV.foreach(@file_path, col_sep: @file_col_sep, headers: true) do |row|
        @records << Record.new(*row.fields)
      end
    end
  end

  def dump
    CSV.open(@file_path, "w", col_sep: @file_col_sep) do |csv|
      csv << Record.column_names
      @records.each do |record|
        csv << record.values
      end
    end
  end
end
