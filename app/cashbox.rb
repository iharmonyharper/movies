module Cashbox
  require 'money'
  I18n.enforce_available_locales = false
  #
  # def Cashbox.included(obj)
  #     obj.init_cashbox
  # end

  def Cashbox.extended(cls)
    cls.init_cashbox
  end


  def init_cashbox
    @money =  Money.from_amount(0)
  end

  def cash
    @money || Money.from_amount(0)
  end

 def take(who)
    raise unless who == 'Bank'
    puts 'Проведена инкассация'
    @money = Money.from_amount(0)
  end

  def add_balance(amount)
    @money += amount if amount.positive?
  end

  def subtract_balance(amount)
    @money -= amount if amount.positive?
  end

end
