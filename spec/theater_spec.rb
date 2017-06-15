describe Theater do

    before(:each) do
      movies = [
      @movie_a = {title: 'The Terminator', year: 2000, genre: 'Action,Sci-Fi', rating: 8.2},
      @movie_b = {title: 'The General', year: 1921, genre: 'Action,Adventure,Comedy', rating: 8.2},
      @movie_c = {title: 'The Kid', year: 1921, genre: 'Comedy,Drama,Family', rating: 8.2},
      @movie_d = {title: 'The Wolf of Wall Street', year: 2000, genre: 'Comedy,Crime', rating: 8.2},
      @movie_e = {title: 'Nausicaä of the Valley of the Wind', year: 2000, genre: 'Adventure,Fantasy', rating: 8.2},
      @movie_f = {title: '3 Idiots', year: 2000, genre: 'Comedy,Drama', rating: 8.2},
      @movie_g = {title: 'The Thing', year: 1982, genre: 'Horror', rating: 8.2},
      @movie_h = {title: 'Rocky', year: 2000, genre: 'Drama', rating: 8.2}
      ]

      @collection = MovieCollection.new(title: 'TestCollection', collection_raw_data: movies )
      @theater = Theater.new(movies_collection: @collection)



      @theater.schedule =  { morning: ['09:00', '12:00'] ,
                             day:  ['14:00', '17:00'] ,
                             evening:  ['19:00', '22:00'],
                             never: ['Not found']}

    end

    context 'want to know when can see movie'
  [
    ['The Terminator', :never], # action,sci-fi
    ['The General', :morning], # :ancient action,adventure,comedy
    ['The Kid', :evening], # :ancient but comedy,drama,family
    ['The Wolf of Wall Street', :day], # comedy,crime
    ['Nausicaä of the Valley of the Wind', :day], # adventure,fantasy
    ['3 Idiots', :evening], # comedy,drama
    ['The Thing', :evening], # horror
    ['Rocky', :evening] # drama
  ].each do |title, time|
    it "#when? movie'#{title}'" do
      expect(@theater.when?(title)).to eq(@theater.schedule[time].join(' - '))
    end
  end



context 'theater is open' do
    it '#show movie according to selected time: morning' do
     expect {print @theater.show('09:00')}.to output("Now showing: The General #{Time.now} - < duration unknown >").to_stdout
  end

    it '#show movie according to selected time: day' do
      movies = ["Now showing: The Wolf of Wall Street #{Time.now} - < duration unknown >",
                "Now showing: Nausicaä of the Valley of the Wind #{Time.now} - < duration unknown >"]
      expect(movies).to include @theater.show('14:00')
    end


    it '#show movie according to selected time: evening' do
      movies = ["Now showing: 3 Idiots #{Time.now} - < duration unknown >",
                "Now showing: The Thing #{Time.now} - < duration unknown >",
                "Now showing: Rocky #{Time.now} - < duration unknown >",
                "Now showing: The Kid #{Time.now} - < duration unknown >"
      ]

      expect(movies).to include @theater.show('19:00')
    end
  end

    context 'theater is closed or no movies for selected time' do
      %w{07:00, 12:00, 00:00}.each do |time|
        it '#show movie according to selected time' do
          expect {print @theater.show(time)}.to output('No movies for this time').to_stdout
        end
      end
    end
end



