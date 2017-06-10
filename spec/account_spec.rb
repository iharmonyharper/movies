describe Account do
  include_context 'test data'

  it 'is available as described_class' do
    expect(described_class).to eq(Account)
  end

  it 'Account#deposit' do
    account.deposit(1.00)
    expect(customer.account.balance).to eq 1.00
  end

  it 'Account#withdraw' do
    account.deposit(1.00)
    account.withdraw(1.00)
    expect(account.balance).to eq 0.00
  end

  it '#withdraw raise exception if not enough money' do
    expect { account.withdraw(1.00) }.to raise_error(AccountError, 'Not enough balance for Customer')
  end
end
