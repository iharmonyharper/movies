describe Customer do
  include_context 'test data'

  it 'is available as described_class' do
    expect(described_class).to eq(Customer)
  end

  it 'Customer#deposit' do
    customer.deposit(1.00)
    expect(customer.account.balance).to eq 1.00
  end

  it 'Customer#pay' do
    customer.deposit(1.00)
    customer.pay(1.00)
    expect(customer.account.balance).to eq 0.00
  end

  it '#withdraw raise exception if not enough money' do
    expect { customer.pay(1.00) }.to raise_error(AccountError, 'Not enough balance for Customer')
  end
end
