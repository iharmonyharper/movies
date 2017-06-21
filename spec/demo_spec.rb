module Cinematic
describe 'Demo on data from csv' do
  let(:movies) do
    data = CsvToHashConverter.new(file_name: 'movies.txt', headers: HEADERS).data
    MovieCollection.new(title: 'My collection', collection_raw_data: data, movie_class: Movies::Movie)
  end
  let(:movie) { movies.filter(title: 'The Terminator').first }
  let(:netflix) { Theaters::Netflix.new(movies_collection: movies) }
  let(:theater) { Theaters::Theater.new(movies_collection: movies) }
  let(:base_theater) { Theaters::BaseTheater.new(movies_collection: movies) }
  let(:ticket_price) { 3.00 }
  let(:money) { 25.00 }

  it 'to check if load from csv is still working' do
    expect(movies.all.count).to eq(250)
  end

  it 'netflix #show' do
    netflix.pay(money)
    t = Time.now
    movie_duration = '67 min'.to_i * 60
    start_time = t.strftime('%H:%M')
    end_time = (t + movie_duration).strftime('%H:%M')
    expect(netflix.show(title: 'The General')).to match(/Now showing: The General #{start_time} - #{end_time}/)
  end

  %w[09:00 14:00 19:00].each do |time|
    it "theater #show when #{time}" do
      expect(theater.show(time)).to match(/#{time}/)
    end
  end
end
end

