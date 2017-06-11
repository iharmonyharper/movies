shared_context 'test data' do
  let(:movies) do
    data = CsvToHashConverter.new(file_name: 'movies.txt', headers: HEADERS).data
    MovieCollection.new(title: 'My collection', collection_raw_data: data)
  end
  let(:movie) { movies.filter(title: 'The Terminator').first }
  let(:netflix) { Netflix.new(movies_collection: movies) }
  let(:theater) { Theater.new(movies_collection: movies) }
  let(:base_theater) { BaseTheater.new(movies_collection: movies) }
  let(:ticket_price) { 3.00 }
  let(:money) { 25.00 }
end
