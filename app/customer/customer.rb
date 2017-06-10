class Customer
  attr_reader :name, :account, :theatres
  def initialize(name:, account: nil, theatres: [])
    @name = name
    @theatres = theatres
    @account = account || Account.new(owner: self)
  end

  def deposit(amount)
    account.deposit(amount)
  end

  def pay(amount)
    account.withdraw(amount)
  end
end
