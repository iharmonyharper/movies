require 'date'
require 'ostruct'
require 'json'

class Movie < OpenStruct
  def initialize(args = {})
    args.each do |k, v|
      unless k == :movies_collection
        value = v.split(/\s{0},\s{0}/)
        args[k] = value.count > 1 ? value : value[0]
      end
    end
    args[:rating] = args[:rating].to_f.round(2)
    args[:year] = args[:year].to_i
    super(args)
  end

  def premier_month
    Date.strptime(date, '%Y-%m').mon rescue nil
  end

  def premier_day
    Date.strptime(date, '%Y-%m-%d').day rescue nil
  end

  def premier_year
    Date.strptime(date, '%Y').year rescue nil
  end

  def has_genre?(name)
    if movies_collection.genres.include?(name)
      genre.include?(name)
    else
      raise("Genre '#{name}' is not found in collection '#{movies_collection.title}'")
    end
  end

  def pretty_print
    JSON.pretty_generate(self.to_h)
  end

  def to_s
    "#{calculate_rating}(#{rating}); #{title} (#{date}; #{genre}) - #{duration}) | link #{link}; year #{year}; country #{country}; director #{director}; actors #{actors}"
  end

  alias :inspect :pretty_print

  private
  def calculate_rating
    asterisk_number = ((rating.to_f - 8.0).round(1) * 10)
    asterisk_number > 0 ? '*' * asterisk_number : '*'
  end

end