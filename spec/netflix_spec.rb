describe Netflix do
  include_context 'test data'

  it 'is available as described_class' do
    expect(netflix.class).to eq(described_class)
    expect(netflix.class.superclass).to eq(base_theater.class)
  end

  it '#show movie' do
    netflix.pay(money)
    expect(netflix.balance).to eq(money)
    expect(netflix.show(movie)).to eq('Now showing: (The Terminator) (время начала) - (время окончания)')
    expect(netflix.balance).to eq(money - ticket_price)
  end

  [{ title: 'The Terminator' },
   { title: /terminator$/i }].each do |movie|
    it '#show movie with filter' do
      netflix.pay(money)
      expect(netflix.balance).to eq(money)
      expect(netflix.show(movie)).to eq('Now showing: (The Terminator) (время начала) - (время окончания)')
      expect(netflix.balance).to eq(money - ticket_price)
    end
  end

  it '#how_much?' do
    expect(movie.ticket_price).to eq(ticket_price)
    expect(netflix.how_much?('The Terminator')).to eq(movie.ticket_price)
  end
end
