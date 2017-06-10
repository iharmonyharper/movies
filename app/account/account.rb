class Account
  attr_reader :balance, :owner

  def initialize(owner:)
    @owner = owner
    @balance = 0.00
  end

  def deposit(amount)
    raise 'Invalid deposit!' unless amount
    @balance += amount
  end

  def withdraw(amount)
    raise(AccountError, "Not enough balance for #{owner.class}") if (@balance - amount) < 0.00
    @balance -= amount
  end
end

class AccountError < StandardError
end
