require 'date'
require 'json'

class Movie
  attr_reader :movies_collection,
              :link,
              :title,
              :year,
              :country,
              :date,
              :genre,
              :duration,
              :rating,
              :director,
              :actors,
              :ticket_price

  MOVIES_CATALOG = { 'AncientMovie' => { ticket_price: 1.00, period: :ancient, year: (1900...1945) },
                     'ClassicMovie' => { ticket_price: 1.50, period: :classic, year: (1945...1968) },
                     'ModernMovie' => { ticket_price: 3.00, period: :modern, year: (1968...2000) },
                     'NewMovie' => { ticket_price: 5.00, period: :new, year: (2000...2100) } }.freeze

  def initialize(movies_collection: [], **args)
    @link = args[:link]
    @title = args[:title]
    @year = args[:year].to_i
    @country = args[:country]
    @date = args[:date]
    @genre = begin
               args[:genre].split(/\s{0},\s{0}/)
             rescue
               [args[:genre]]
             end
    @duration = args[:duration]
    @rating = args[:rating]
    @director = args[:director]
    @actors = begin
                args[:actors].split(/\s{0},\s{0}/)
              rescue
                [args[:actors]]
              end
    @ticket_price = args[:ticket_price]
    @movies_collection = movies_collection
  end

  def self.build(movies_collection: [], data: {})
    movie_class = Movie::MOVIES_CATALOG.detect do |_k, v|
      v[:year].cover?(data[:year].to_i)
    end.first
    Object.const_get(movie_class).new(movies_collection: movies_collection, **data)
  end

  def genres
    [@genre].join(',')
  end

  def rating
    @rating || 0.0
  end

  def year
    @year.to_i
  end

  def period
    self.class.to_s.split('Movie').first.downcase.to_sym
  end

  def ticket_price
    @ticket_price || MOVIES_CATALOG[self.class.to_s][:ticket_price]
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

  def matches?(**filter)
    filter.all? do |f, value|
      if f == :exclude?
        exclude?(**value)
      else
        value === send(f)
      end
    end
  end

  def exclude?(**filter)
    !matches?(**filter)
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
