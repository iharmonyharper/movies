describe 'Demo' do
 include_context 'test data'

it 'demo' do
  #to check if load from csv is still working
  expect(movies.all.count).to eq(250)
end
end



