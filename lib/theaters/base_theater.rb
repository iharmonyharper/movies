module Theaters
  class MovieSearchError < StandardError
  end

  class BaseTheater
    attr_accessor :movies_collection

    def initialize(movies_collection: [])
      @movies_collection = movies_collection
    end

    def show(movie = nil, **filter, &block)
      movie ||= find_movies_to_show(movie, **filter, &block)
      time = start_time(movie)
      if movie.duration
        "Now showing: #{movie.title} #{time.strftime('%H:%M')} - #{(time + (movie.duration.to_i * 60)).strftime('%H:%M')}"
      else
        "Now showing: #{movie.title} #{time.strftime('%H:%M')} - < duration unknown >"
      end
    end

    def find_movies_to_show(movie = nil, **filter, &block)
      movie ||= random_movie(movies_collection.filter(**filter, &block))
      raise(MovieSearchError, "No results for '#{filter}'") unless movie
      movie
    end

    def how_much?(movie_title)
      movies_collection.filter(title: movie_title).first.ticket_price
    end

    private

    def random_movie(movies)
      movies.sort_by { |m| m.rating * rand }.last
    end
  end
end
