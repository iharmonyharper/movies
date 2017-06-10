require 'csv'

class CsvToHashConverter
  attr_reader :data

  def initialize(file_name: nil, headers: false)
    @file_name = file_name
    @headers = headers
    raise "File '#{@file_name}' is not found" unless File.exist?(@file_name)
    @data = CSV.read(@file_name, headers: @headers, col_sep: '|').map(&:to_h)
  end
end
