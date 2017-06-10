require_relative '../movie_collection'

class BaseTheater
  attr_reader :account, :movies_collection, :ticket_price
  attr_accessor :customer

  TOP = 10

  def initialize(account: nil, movies_collection: [])
    @account = account || Account.new(owner: self)
    @movies_collection = movies_collection
  end

  def show(_movie = nil, **filter)
    raise 'No customer!' unless customer
    movie = _movie || random_movie(movies_collection.filter(filter))
    customer.pay(movie.ticket_price)
    account.deposit(movie.ticket_price)
    customer = nil
    "Now showing: (#{movie.title}) (время начала) - (время окончания)"
  end

  def how_much?(movie_title)
    movies_collection.filter(title: movie_title)[0].ticket_price
  end

  private

  def random_movie(movies)
    movies.sort_by(&:rating).last(TOP).sample(1)[0]
  end
end
