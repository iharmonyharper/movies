describe 'Demo on data from csv' do

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


  it 'to check if load from csv is still working' do
    expect(movies.all.count).to eq(250)
  end

  it 'netflix #show' do
    netflix.pay(money)
    t = Time.now
    movie_duration = '67 min'.to_i * 60
    start_time = t.strftime('%H:%M')
    end_time = (t + movie_duration).strftime('%H:%M')
    expect { print netflix.show(title: 'The General') }.to output(/Now showing: The General #{start_time} - #{end_time}/).to_stdout
  end

  %w[09:00 14:00 19:00].each do |time|
  it "theater #show when #{time}" do
    expect { print theater.show(time) }.to output(/#{time}/).to_stdout
    end
  end
end
