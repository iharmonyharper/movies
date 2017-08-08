module Cinematic
describe 'Demo on data from csv' do
  let(:movies) do
    data = CsvToHashConverter.new(file_name: 'movies.txt', headers: HEADERS).data
    MovieCollection.new(title: 'My collection', collection_raw_data: data, movie_class: Movies::Movie)
  end
  let(:movies_new) do
    data = CsvToHashConverter.new(file_name: 'movies.txt', headers: HEADERS).data
    MovieCollection.new(title: 'My collection', collection_raw_data: data, movie_class: Movies::Movie)
  end
  let(:movie) { movies.filter(title: 'The Terminator').first }
  let(:movie_new) { movies.filter(title: 'The General').last }
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
    expect(netflix.show(title: 'The General', period: :ancient)).to match(/Now showing: The General #{start_time} - #{end_time}/)
  end

  it 'netflix #show with block in filter' do
    netflix.pay(money)
    a=netflix.show { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003}
    expected_movies = movies.select{ |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003}
    expect(expected_movies.map(&:title).any? {|t| a.match(t)}).to be_truthy
  end

  it 'netflix #define custom filter' do
    netflix.pay(money)
    netflix.define_filter(:new_sci_fi) { {genre: 'Sci-Fi', period: :modern } }
    expect(netflix.show(new_sci_fi: true, title: /The/ ){ |movie| movie.director.include?('Cam')})
        .to match('Now showing: The Terminator ')

  end

  it 'netflix #define custom filter with additional params' do
    netflix.pay(3.00)
    netflix.define_filter(:new_sci_fi) { |movie, year| movie.year > year && movie.genre.include?('Sci-Fi')}
    expect(netflix.show(new_sci_fi: 1985, actors: 'Arnold Schwarzenegger'))
        .to match('Now showing: Terminator 2: Judgment Day ') { |movie| movie.title.include?('Terminator')}
  end


  it 'netflix #define custom filter from another filter with additional parameter' do
    netflix.pay(money)
    netflix.define_filter(:new_sci_fi) { |movie, year| movie.year > year && movie.genre.include?('Sci-Fi')}
    netflix.define_filter(:newest_sci_fi, from: :new_sci_fi, arg: 2014)
    expect(netflix.show(newest_sci_fi: true))
        .to match('Now showing: Mad Max: Fury Road ')
  end


  %w[09:00 14:00 19:00].each do |time|
    it "theater #show when #{time}" do
      expect(theater.show(time)).to match(/#{time}/)
    end
  end
end
end

