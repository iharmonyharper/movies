describe Netflix do
  include_context 'test data'

  it 'is available as described_class' do
    expect(netflix.class).to eq(described_class)
  end

  it '#show movie' do
    netflix.customer = customer
    customer.deposit(money)
    expect(customer.account.balance).to eq(money)
    expect(netflix.show(movie)).to eq('Now showing: (The Terminator) (время начала) - (время окончания)')
    expect(customer.account.balance).to eq(money - ticket_price)
    expect(netflix.account.balance).to eq(ticket_price)
  end

  it '#show with filters ' do
    netflix.customer = customer
    customer.deposit(money)
    expect(customer.account.balance).to eq(money)
    expect(netflix.show(title: /terminator$/i)).to eq('Now showing: (The Terminator) (время начала) - (время окончания)')
    expect(customer.account.balance).to eq(money - ticket_price)
    expect(netflix.account.balance).to eq(ticket_price)
  end

  it '#how_much?' do
    expect(movie.ticket_price).to eq(ticket_price)
    expect(netflix.how_much?('The Terminator')).to eq(movie.ticket_price)
  end
end
