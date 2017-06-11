require 'date'
require 'json'

class Movie
  attr_reader :movies_collection, :period
  attr_accessor :ticket_price

  MOVIES_CATALOG = { 'AncientMovie' => { ticket_price: 1.00, period: :ancient, year: (1900...1945) },
                     'ClassicMovie' => { ticket_price: 1.50, period: :classic, year: (1945...1968) },
                     'ModernMovie' => { ticket_price: 3.00, period: :modern, year: (1968...2000) },
                     'NewMovie' => { ticket_price: 5.00, period: :new, year: (2000...2100) } }.freeze

  def initialize(movies_collection: [], **args)
    args.each do |k, v|
      value = v.split(/\s{0},\s{0}/)
      self.class.send(:attr_reader, k)
      instance_variable_set("@#{k}", value.count > 1 ? value : value[0])
    end
    @rating = @rating.to_f.round(2)
    @year = @year.to_i
    @period = Movie.movies_catalog[self.class.to_s][:period]
    @ticket_price = Movie.movies_catalog[self.class.to_s][:ticket_price]
    @movies_collection = movies_collection
  end

  def premier_month
    Date.strptime(date, '%Y-%m').mon
  rescue
    nil
  end

  def premier_day
    Date.strptime(date, '%Y-%m-%d').day
  rescue
    nil
  end

  def premier_year
    Date.strptime(date, '%Y').year
  rescue
    nil
  end

  def has_genre?(name)
    raise("Genre '#{name}' is not found in collection '#{movies_collection.title}'") unless movies_collection.genres.include?(name)
    genre.include?(name)
  end

  def self.movies_catalog
    MOVIES_CATALOG
  end

  def pretty_print
    JSON.pretty_generate(to_h)
  end

  alias inspect pretty_print

  private

  def calculate_rating
    asterisk_number = ((rating - 8.0).round(1) * 10)
    asterisk_number > 0 ? '*' * asterisk_number : '*'
  end
end
