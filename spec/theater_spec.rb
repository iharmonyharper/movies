describe Theater do
  include_context 'test data'

  it 'is available as described_class' do
    expect(theater.class).to eq(described_class)
    expect(theater.class.superclass).to eq(base_theater.class)
  end

  [
    ['The Terminator', :never], # Action,Sci-Fi
    ['The General', :morning], # ancient Action,Adventure,Comedy
    ['The Kid', :evening], # ancient but Comedy,Drama,Family
    ['The Wolf of Wall Street', :day], # comedy,crime
    ['Nausicaä of the Valley of the Wind', :day], # adventure,fantasy
    ['3 Idiots', :evening], # comedy,drama
    ['The Thing', :evening], # horror
    ['Rocky', :evening] # drama
  ].each do |title, time|
    it "#when? movie'#{title}'" do
      expect(theater.when?(title)).to eq(time)
    end
  end

  %i[morning day evening].each do |time|
    it '#show movie according to selected time' do
      theater.pay(money)
      possible_movies = theater.movies_collection.filter(theater.filters(time)).map do |movie|
        "Now showing: (#{movie.title}) (время начала) - (время окончания)"
      end
      expect(possible_movies).to include(theater.show(time))
    end
  end
end
