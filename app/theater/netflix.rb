require_relative 'base_theater'

class Netflix < BaseTheater
  attr_reader :balance

  def initialize( movies_collection: [])
    super
    @balance = 0
  end

  def show(**filter)
    super { |movie|
      withdraw(movie.ticket_price)
    }
  end

  def pay(amount)
    raise(PaymentError, 'Invalid payment operation') if amount.negative?
    @balance += amount
  end

  private
  def withdraw(amount)
    raise(AccountBalanceError, "Not enough balance for #{self.class}") if (@balance - amount).negative?
    @balance -= amount
  end

end

class AccountBalanceError < StandardError
end
class PaymentError < StandardError
end
