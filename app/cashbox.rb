module Cashbox
  require 'money'
  I18n.enforce_available_locales = false

  attr_accessor :money

  def cash
    @money || Money.from_amount(0)
  end

  alias :money :cash

  def take(who)
    raise unless who == 'Bank'
    puts 'Проведена инкассация'
    self.money = Money.from_amount(0)
  end

  def add_balance(amount)
    self.money += amount if amount.positive?
  end

  def subtract_balance(amount)
    self.money -= amount if amount.positive?
  end

end
