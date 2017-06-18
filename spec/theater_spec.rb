require 'spec_helper'
describe Theater do
  let(:movies) do
    [
      { title: 'The Terminator', year: 2000, genre: 'Action,Sci-Fi', rating: 8.2, duration: '90min', actors: ''  },
      { title: 'The General', year: 1921, genre: 'Action,Adventure,Comedy', rating: 8.2, actors: '' },
      { title: 'The Kid', year: 1921, genre: 'Comedy,Drama,Family', rating: 8.2, duration: '90min', actors: '' },
      { title: 'The Wolf of Wall Street', year: 2000, genre: 'Comedy,Crime', rating: 8.2, duration: '90min', actors: '' },
      { title: 'Nausicaä of the Valley of the Wind', year: 2000, genre: 'Adventure,Fantasy', rating: 8.2, duration: '90min', actors: '' },
      { title: '3 Idiots', year: 2000, genre: 'Comedy,Drama', rating: 8.2, duration: '90min', actors: '' },
      { title: 'The Thing', year: 1982, genre: 'Horror', rating: 8.2, duration: '90min', actors: '' },
      { title: 'Rocky', year: 2000, genre: 'Drama', rating: 8.2, duration: '90min', actors: '' }
    ]
  end

  let(:collection) { MovieCollection.new(title: 'TestCollection', collection_raw_data: movies) }
  let(:theater) { Theater.new(movies_collection: collection) }

  before do
    theater.filters = { morning: { period: :ancient,
                                   exclude?: { genres: /(drama)|(horror)/i } },

                        evening: { genres: /(drama)|(horror)/i },

                        day: { genres: /(comedy)|(adventure)/i,
                               exclude?: { period: :ancient, genres: /(drama)|(horror)/i } } }

    theater.schedule = { morning: ('09:00'...'12:00'),
                         day: ('14:00'..'17:00'),
                         evening: ('19:00'...'22:00')}
  end

  context 'want to know when can see movie'
    context 'when movie can be seen'
  [
    ['The General', :morning], # :ancient action,adventure,comedy
    ['The Kid', :evening], # :ancient but comedy,drama,family
    ['The Wolf of Wall Street', :day], # comedy,crime
    ['Nausicaä of the Valley of the Wind', :day], # adventure,fantasy
    ['3 Idiots', :evening], # comedy,drama
    ['The Thing', :evening], # horror
    ['Rocky', :evening] # drama
  ].each do |title, time|
    it "#when? for #{time} movie'#{title}'" do
      expect(theater.when?(title)).to eq(theater.schedule[time].first)
    end
  end

    context 'when movie is not found'
    # 'The Terminator', genres: action,sci-fi
    it '#when? returns message when movie is not found' do
      expect(theater.when?('The Terminator')).to eq('Not found')
    end


  context 'theater is open' do
    it '#show movie according to selected time: morning' do
      expect(theater.show('09:00')).to eq('Now showing: The General 09:00 - < duration unknown >')
    end

    it '#show movie according to selected time: movie has started' do
      expect(theater.show('09:01')).to eq('Now showing: The General 09:00 - < duration unknown >')
    end

    it '#show movie according to selected time: day' do
      movies = ['Now showing: The Wolf of Wall Street 14:00 - 15:30',
                'Now showing: Nausicaä of the Valley of the Wind 14:00 - 15:30']
      expect(movies).to include theater.show('14:00')
    end

    it '#show movie according to selected time: evening' do
      time = Time.now.strftime('%H:%M')
      movies = [
        'Now showing: 3 Idiots 19:00 - 20:30',
        'Now showing: The Thing 19:00 - 20:30',
        'Now showing: Rocky 19:00 - 20:30',
        'Now showing: The Kid 19:00 - 20:30'
      ]
      expect(movies).to include theater.show('19:00')
    end
  end

  context 'theater is closed or no movies for selected time' do
    %w[07:00 12:00 00:00].each do |time|
      it "#show movie according to selected time: #{time}" do
        expect(theater.show(time)).to eq('No movies for this time')
      end
    end
  end
end
