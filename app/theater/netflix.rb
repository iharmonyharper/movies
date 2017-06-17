require_relative 'base_theater'

class Netflix < BaseTheater
  attr_reader :balance

  def initialize(movies_collection: [])
    super
    @balance = 0
  end

  def when?(movie_title)
    movie = movies_collection.filter(title: movie_title).first
    return 'Not found' unless movie
    Time.now
  end

  def show(**filter)
    super do |movie|
      withdraw(movie.ticket_price)
    end
  end

  def pay(amount)
    raise(PaymentError, 'Invalid payment operation') if amount.negative?
    @balance += amount
  end

  class AccountBalanceError < StandardError
  end
  class PaymentError < StandardError
  end

  private

  def withdraw(amount)
    raise(AccountBalanceError, "Not enough balance for #{self.class}") if (@balance - amount).negative?
    @balance -= amount
  end
end
