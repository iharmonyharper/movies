describe Netflix do

  before(:each) do
    @movie_a = {title: 'Roman Holiday', year: 1953, genre: 'Comedy,Romance', ticket_price: 4, rating: 8.2}
    @movie_b = {title: 'Roman Holiday (new)', year: 2000, genre: 'Comedy', ticket_price: 4, rating: 8.2}
    @collection = MovieCollection.new(title: 'TestCollection', collection_raw_data: [@movie_a, @movie_b])
    @netflix = Netflix.new(movies_collection: @collection)
  end

  context '#pay' do
    subject {@netflix.pay(25) }
    it 'changes balance if payment' do
      expect { subject}.to change {@netflix.balance}.from(0).to(25)
    end
  end

  context 'not enough money to #pay' do
    subject {@netflix.show(title: 'Roman Holiday')}
    it 'raise exception if not enough money' do
      expect {subject}.to raise_error(AccountBalanceError, 'Not enough balance for Netflix')
    end
    it 'NOT changes balance if not not enough money' do
      expect {subject rescue nil}.not_to change {@netflix.balance}
    end
  end


  context '#show with 1 search result' do
    before {@netflix.pay(25) }
    subject {@netflix.show(genre: 'Comedy', period: :classic)}

    it 'shows movie' do
      expect {print subject}.to output("Now showing: Roman Holiday #{Time.now} - < duration unknown >").to_stdout
    end

    it 'changes balance on ticket price amount' do
      expect {subject}.to change {@netflix.balance}.from(25).to(21)
    end
  end

   context 'nothing to #show' do
    before {@netflix.pay(25) }
    subject {@netflix.show(title: 'Not Found')}
    it 'raise exception if no movie' do
      expect {subject}.to raise_error(MovieSearchError, "No results for '{:title=>\"Not Found\"}'")
    end
    it 'NOT changes balance if no movie' do
      expect {subject rescue nil}.not_to change {@netflix.balance}
    end
   end

  context 'with multiple search results' do
    before {@netflix.pay(25) }
    subject {@netflix.show(genre: 'Comedy') }
    it 'shows random movie' do
      expect(["Now showing: Roman Holiday #{Time.now} - < duration unknown >",
              "Now showing: Roman Holiday (new) #{Time.now} - < duration unknown >"]).to include(subject)
    end
    it 'changes balance on ticket price amount' do
      expect {subject}.to change {@netflix.balance}.from(25).to(21)
    end
  end

  context 'with empty filter' do
    before {@netflix.pay(25) }
    subject {@netflix.show() }
    it 'shows random movie' do
      expect(["Now showing: Roman Holiday #{Time.now} - < duration unknown >",
              "Now showing: Roman Holiday (new) #{Time.now} - < duration unknown >"]).to include(subject)
    end
    it 'changes balance on ticket price amount' do
      expect {subject}.to change {@netflix.balance}.from(25).to(21)
    end
  end

end





