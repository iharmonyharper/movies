describe BaseTheater do
  include_context 'test data'

  it 'is available as described_class' do
    expect(base_theater.class).to eq(described_class)
  end

  it '#show movie' do
    customer.deposit(25.00)
    movie.ticket_price = 0.4
    base_theater.customer = customer
    expect(base_theater.account.balance).to be >= 0.00

    3.times do
      _customer_balance = customer.account.balance
      _base_theatre_balance = base_theater.account.balance
      puts "Before transaction: #{_customer_balance}  #{_base_theatre_balance}"

      base_theater.show(movie)
      _expected = _customer_balance - movie.ticket_price
      expect(customer.account.balance).to eq(_expected >= 0.00 ? _expected : _customer_balance)
      expect(base_theater.account.balance).to eq(_expected >= 0.00 ? _base_theatre_balance + movie.ticket_price : _base_theatre_balance)

      _expected = (_customer_balance - movie.ticket_price) + (_base_theatre_balance + movie.ticket_price)
      expect(customer.account.balance + base_theater.account.balance).to eq(_expected >= 0.00 ? _expected : 0.00)
    end
  end

  it '#show movie according to filter' do
    customer.deposit(25.00)
    base_theater.customer = customer
    expect(base_theater.account.balance).to be >= 0.00
    movie = base_theater.movies_collection.filter(genre: 'Comedy', period: :classic)[0]
    puts movie

    3.times do
      _customer_balance = customer.account.balance
      _base_theatre_balance = base_theater.account.balance
      puts "Before transaction: #{_customer_balance}  #{_base_theatre_balance}"
      base_theater.show(genre: 'Comedy', period: :classic)
      _expected = _customer_balance - movie.ticket_price
      expect(customer.account.balance).to eq(_expected >= 0.00 ? _expected : _customer_balance)
      expect(base_theater.account.balance).to eq(_expected >= 0.00 ? _base_theatre_balance + movie.ticket_price : _base_theatre_balance)

      _expected = (_customer_balance - movie.ticket_price) + (_base_theatre_balance + movie.ticket_price)
      expect(customer.account.balance + base_theater.account.balance).to eq(_expected >= 0.00 ? _expected : 0.00)
    end
  end
end
