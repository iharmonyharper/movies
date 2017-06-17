describe Netflix do
  before(:each) do
    @movie_a = { title: 'Roman Holiday', year: 1953, genre: 'Comedy,Romance', ticket_price: 4, rating: 8.2 }
    @movie_b = { title: 'Roman Holiday (new)', year: 2000, genre: 'Comedy', ticket_price: 4, rating: 8.2 }
    @collection = MovieCollection.new(title: 'TestCollection', collection_raw_data: [@movie_a, @movie_b])
    @netflix = Netflix.new(movies_collection: @collection)
    @expected_show_output = proc { |title, duration = nil|
      time = Time.now
      if duration
        "Now showing: #{title} #{time.strftime('%H:%M')} - #{(time + (duration * 60)).strftime('%H:%M')}"
      else
        "Now showing: #{title} #{time.strftime('%H:%M')} - < duration unknown >"
      end
    }
  end

  context '#pay' do
    subject { @netflix.pay(25) }
    it 'changes balance if payment' do
      expect { subject }.to change { @netflix.balance }.from(0).to(25)
    end
  end

  context 'not enough money to #pay' do
    subject { @netflix.show(title: 'Roman Holiday') }
    it 'raise exception if not enough money' do
      expect { subject }.to raise_error(Netflix::AccountBalanceError, 'Not enough balance for Netflix')
    end
    it 'NOT changes balance if not not enough money' do
      expect do
        begin
                subject
              rescue
                nil
              end
      end.not_to change { @netflix.balance }
    end
  end

  context '#show with 1 search result' do
    before { @netflix.pay(25) }
    subject { @netflix.show(genre: 'Comedy', period: :classic) }

    it 'shows movie' do
      expect { print subject }.to output(@expected_show_output.call('Roman Holiday')).to_stdout
    end

    it 'changes balance on ticket price amount' do
      expect { subject }.to change { @netflix.balance }.from(25).to(21)
    end
  end

  context 'nothing to #show' do
    before { @netflix.pay(25) }
    subject { @netflix.show(title: 'Not Found') }
    it 'raise exception if no movie' do
      expect { subject }.to raise_error(Netflix::MovieSearchError, "No results for '{:title=>\"Not Found\"}'")
    end
    it 'should not change balance if no movie' do
      expect{subject rescue nil}.not_to change { @netflix.balance }
    end
  end

  context 'with multiple search results' do
    before { @netflix.pay(25) }
    subject { @netflix.show(genre: 'Comedy') }
    it 'shows random movie' do
      expect([@expected_show_output.call('Roman Holiday'),
              @expected_show_output.call('Roman Holiday (new)')]).to include(subject)
    end
    it 'changes balance on ticket price amount' do
      expect { subject }.to change { @netflix.balance }.from(25).to(21)
    end
  end

  context 'with empty filter' do
    before { @netflix.pay(25) }
    subject { @netflix.show }
    it 'shows random movie' do
      expect([@expected_show_output.call('Roman Holiday'),
              @expected_show_output.call('Roman Holiday (new)')]).to include(subject)
    end
    it 'changes balance on ticket price amount' do
      expect { subject }.to change { @netflix.balance }.from(25).to(21)
    end
  end
end
