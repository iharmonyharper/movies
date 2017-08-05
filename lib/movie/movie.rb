module Movies
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

    include Enumerable

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
      @genre = args[:genre].split(/\s*,\s*/)
      @duration = args[:duration]
      @rating = args[:rating]
      @director = args[:director]
      @actors = args[:actors].split(/\s*,\s*/)
      @ticket_price = args[:ticket_price]
      @movies_collection = movies_collection
    end

    def self.build(movies_collection: [], data: {})
      movie_class = Movie::MOVIES_CATALOG.detect do |_k, v|
        v[:year].cover?(data[:year].to_i)
      end.first
      Object.const_get(name.split('::').first).const_get(movie_class).new(movies_collection: movies_collection, **data)
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
      split_to_module_and_class.last.sub('Movie', '').downcase.to_sym
    end

    def ticket_price
      @ticket_price || MOVIES_CATALOG[split_to_module_and_class.last][:ticket_price]
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
          match_filters?(f, value)
        end
      end
    end

    def exclude?(**filter)
      filter.none? { |f, value| match_filters?(f, value) }
    end

    def custom_filter
      yield(itself)
    end

    def pretty_print
      JSON.pretty_generate(to_h)
    end

    alias inspect pretty_print

    def <=>(other)
      title <=> other.title
    end

    private

    def match_filters?(f, value)
      value === send(f) || (Array === send(f) ? send(f).include?(value.to_s) : false)
    end

    def calculate_rating
      asterisk_number = ((rating - 8.0).round(1) * 10)
      asterisk_number > 0 ? '*' * asterisk_number : '*'
    end

    def split_to_module_and_class
      self.class.name.split('::')
    end
  end
end
