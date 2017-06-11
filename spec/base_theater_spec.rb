describe BaseTheater do
  include_context 'test data'

  it 'is available as described_class' do
    expect(base_theater.class).to eq(described_class)
  end

  it '#pay should add money to balance' do
    base_theater.pay(1.00)
    expect(base_theater.balance).to eq 1.00
  end

  [-0.01, -1].each do |amount|
    it "#pay should raise exception if negative amount (#{amount}" do
      expect { base_theater.pay(amount) }.to raise_error(PaymentError, 'Invalid payment operation')
    end
  end

  it '#show should withdraw money from balance' do
    base_theater.pay(money)
    base_theater.show(movie)
    expect(base_theater.balance).to eq(money - movie.ticket_price)
  end

  [0.00, 0, 0.01, -0, -0.00, 0.0000000001].each do |balance|
    it "#withdraw raise exception if not enough money (balance=#{balance})" do
      base_theater.pay(balance)
      expect(base_theater.balance).to eq(balance)
      expect { base_theater.show(movie) }.to raise_error(AccountBalanceError, 'Not enough balance for BaseTheater')
    end
  end

  it '#withdraw raise exception if not enough money' do
    base_theater.pay(movie.ticket_price * 3 - 0.01)
    expect(base_theater.balance).to eq(movie.ticket_price * 3 - 0.01)
    2.times { base_theater.show(movie) }
    expect { base_theater.show(movie) }.to raise_error(AccountBalanceError, 'Not enough balance for BaseTheater')
  end

  it '#show movie according to filter' do
    base_theater.pay(money)
    filter = { genre: 'Comedy', period: :classic }
    movie = base_theater.movies_collection.filter(filter).first
    base_theater.show(filter)
    expect(base_theater.balance).to eq(money - movie.ticket_price)
  end
end
