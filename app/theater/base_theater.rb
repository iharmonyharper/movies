require_relative '../movie_collection'

class BaseTheater
  attr_reader :movies_collection, :balance

  def initialize(account: nil, movies_collection: [])
    @balance = 0.00
    @movies_collection = movies_collection
  end

  def show(movie = nil, **filter)
    movie ||= random_movie(movies_collection.filter(filter))
    withdraw(movie.ticket_price)
    "Now showing: (#{movie.title}) (время начала) - (время окончания)"
  end

  def how_much?(movie_title)
    movies_collection.filter(title: movie_title).first.ticket_price
  end

  def pay(amount)
    raise(PaymentError, 'Invalid payment operation') if amount.to_f.round(2) < 0.00
    @balance += amount
  end

  private

  def random_movie(movies)
    movies.sort_by { |m| m.rating * rand }.last
  end

  def withdraw(amount)
    raise(AccountBalanceError, "Not enough balance for #{self.class}") if (@balance - amount) < 0.00
    @balance -= amount
  end
end

class AccountBalanceError < StandardError
end
class PaymentError < StandardError
end
