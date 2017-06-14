require_relative '../movie_collection'

class MovieSearchError < StandardError
end


class BaseTheater
  attr_accessor :movies_collection

  def initialize(movies_collection: [])

    @movies_collection = movies_collection
  end

  def show(movie = nil, **filter)
    movie ||= random_movie(movies_collection.filter(filter))
    raise(MovieSearchError,"No results for '#{filter}'") unless movie
    yield(movie) if block_given?
    "Now showing: (#{movie.title}) (время начала) - (время окончания)"
  end

  def how_much?(movie_title)
    movies_collection.filter(title: movie_title).first.ticket_price
  end



  private
  def random_movie(movies)
    movies.sort_by { |m| m.rating * rand }.last
  end

end

