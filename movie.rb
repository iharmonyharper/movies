require 'date'
require 'ostruct'

class Movie < OpenStruct
  def initialize(args = {})
    args.each do |k, v|
      value = v.split(/\s{0},\s{0}/)
      args[k] = value.count > 1 ? value : value[0]
    end
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
    genre.include? name
  end

  def calculate_rating(rating_float)
    asterisk_number = ((rating_float.to_f - 8.0).round(1) * 10)
    asterisk_number > 0 ? '*' * asterisk_number : '*'
  end

  def to_s
    "#{calculate_rating(rating)}(#{rating}); #{name} (#{date}; #{genre}) - #{duration}) | link #{link}; year #{year}; country #{country}; director #{director}; actors #{actors}"
  end

  def inspect
    self.to_h
  end

end