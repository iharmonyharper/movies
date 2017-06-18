describe Netflix do
  let(:old_romance_comedy) { { title: 'Roman Holiday', year: 1953, genre: 'Comedy,Romance', ticket_price: 4, rating: 8.2, duration: 90 } }
  let(:new_drama_comedy) { { title: 'Roman Holiday (new)', year: 2000, genre: 'Comedy,Drama', ticket_price: 4, rating: 8.2, duration: 120 } }
  let(:collection) { MovieCollection.new(title: 'TestCollection', collection_raw_data: [old_romance_comedy, new_drama_comedy]) }
  let(:netflix) { Netflix.new(movies_collection: collection) }

  context '#pay' do
    subject { netflix.pay(25) }
    it 'changes balance if payment' do
      expect { subject }.to change { netflix.balance }.from(0).to(25)
    end
  end

  context 'not enough money to #pay' do
    subject { netflix.show(title: 'Roman Holiday') }
    it 'raise exception if not enough money' do
      expect { subject }.to raise_error(Netflix::AccountBalanceError, 'Not enough balance for Netflix')
    end
    it 'NOT changes balance if not not enough money' do
      expect do
        begin
             subject
           rescue
             Netflix::AccountBalanceError
           end
      end.not_to change(netflix, :balance)
    end
  end

  context '#show with 1 search result' do
    before { netflix.pay(25) }
    subject { netflix.show(genre: 'Romance', period: :classic) }
    it 'shows movie' do
      expect { print subject }.to output("Now showing: Roman Holiday #{Time.now.strftime('%H:%M')} - #{(Time.now + (90 * 60)).strftime('%H:%M')}").to_stdout
    end
    it 'changes balance on ticket price amount' do
      expect { subject }.to change { netflix.balance }.from(25).to(21)
    end
  end

  context 'nothing to #show' do
    before { netflix.pay(25) }
    subject { netflix.show(title: 'Not Found') }
    it 'raise exception if no movie' do
      expect { subject }.to raise_error(Netflix::MovieSearchError, "No results for '{:title=>\"Not Found\"}'")
    end
    it 'should not change balance if no movie' do
      expect{ subject rescue Netflix::MovieSearchError}.not_to change { netflix.balance }
    end
  end

  context 'with multiple search results' do
    before { netflix.pay(25) }
    subject { netflix.show(genre: 'Comedy') }
    it 'shows random movie' do
      expect(subject).to match(/^Now showing: Roman Holiday/)
        .and include('Roman Holiday')
        .or include('Roman Holiday (new)')
    end
    it 'changes balance on ticket price amount' do
      expect { subject }.to change { netflix.balance }.from(25).to(21)
    end
  end

  context 'with empty filter' do
    before { netflix.pay(25) }
    subject { netflix.show }
    it 'shows random movie' do
      expect(subject).to match(/^Now showing: Roman Holiday/)
        .and include('Roman Holiday')
        .or include('Roman Holiday (new)')
    end
    it 'changes balance on ticket price amount' do
      expect { subject }.to change { netflix.balance }.from(25).to(21)
    end
  end
end
