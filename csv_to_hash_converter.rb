require 'csv'

class CsvToHashConverter
  attr_reader :data

  def initialize(args = {})
    @file_name = args.fetch(:file_name)
    @headers = args.fetch(:headers, false)
    raise "File '#{@file_name}' is not found" unless File.exist?(@file_name)
    @data = CSV.read(@file_name, headers: @headers, col_sep: '|').map(&:to_h)
  end
end
