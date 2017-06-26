module Theaters

class Netflix < BaseTheater
  attr_reader :balance

  def initialize(movies_collection: [])
    super
    @balance = Money.from_amount(0)
  end

  def show(**filter)
    super do |movie|
      withdraw(movie.ticket_price)
    end
  end

  def start_time(movie)
    Time.now
  end

  def pay(amount)
    amount = Money.from_amount(amount) unless Money === amount
    raise(PaymentError, 'Invalid payment operation') if amount.negative?
    @balance += amount
    Netflix.add_balance(amount)
  end

  class AccountBalanceError < StandardError
  end
  class PaymentError < StandardError
  end

  private

  def withdraw(amount)
    amount = Money.from_amount(amount)
    raise(AccountBalanceError, "Not enough balance for #{self.class}") if (@balance - amount).negative?
    @balance -= amount
  end
end
end
