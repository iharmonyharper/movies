module Cinematic
  describe Theaters::Netflix do
    let(:old_romance_comedy) {{title: 'Roman Holiday', year: 1953, genre: 'Comedy,Romance', ticket_price: 4, rating: 8.2, duration: 90, actors: 'Gregory Peck,Audrey Hepburn,Eddie Albert'}}
    let(:new_drama_comedy) {{title: 'Roman Holiday (new)', year: 2000, genre: 'Comedy,Drama', ticket_price: 4, rating: 8.2, duration: 120, actors: ''}}
    let(:collection) {MovieCollection.new(title: 'TestCollection', collection_raw_data: [old_romance_comedy, new_drama_comedy], movie_class: Movies::Movie)}
    let(:netflix) {Netflix.new(movies_collection: collection)}
    let(:netflix_new) {Netflix.new(movies_collection: collection)}

    context '#pay' do
      it 'changes balance if payment' do
        old_balance = Netflix.cash
        expect {netflix.pay(25)}.to change {netflix.balance}.from(0).to(Money.from_amount(25))
                                        .and change {Netflix.cash}.from(old_balance).to(old_balance + Money.from_amount(25))
      end

      it 'changes common cashbox balance if payment' do
        old_balance = Netflix.cash
        netflix.pay(25)
        expect {netflix_new.pay(25)}.to change {Netflix.cash}.from(old_balance + Money.from_amount(25))
                                            .to(old_balance + Money.from_amount(50))
      end
    end

    context '#take'
    context '#taken by Bank'
    it 'reset cashbox balance to 0' do
      old_balance = Netflix.cash
      netflix.pay(25)
      netflix_new.pay(25)
      expect {Netflix.take('Bank')}.to change {Netflix.cash}.from(old_balance + Money.from_amount(50)).to(0)
    end
    context '#taken by unauthorized'
    it 'raise exception' do
      netflix.pay(25)
      netflix_new.pay(25)
      expect {Netflix.take('not bank')}.to raise_exception(RuntimeError)
                                               .and avoid_changing(Netflix, :cash)
    end


    context 'not enough money to #pay' do
      subject {netflix.show(title: 'Roman Holiday')}
      it 'raise exception if not enough money' do
        expect {subject}.to raise_error(Netflix::AccountBalanceError, 'Not enough balance for Theaters::Netflix')
                                .and avoid_changing(netflix, :balance)
      end
    end

    context '#show with 1 search result' do
      before {netflix.pay(25)}
      subject {netflix.show(genre: 'Romance', period: :classic)}
      it 'shows movie' do
        expect(subject).to eq("Now showing: Roman Holiday #{Time.now.strftime('%H:%M')} - #{(Time.now + (90 * 60)).strftime('%H:%M')}")
      end
      it 'changes balance on ticket price amount' do
        expect {subject}.to change {netflix.balance}.from(Money.from_amount(25)).to(Money.from_amount(21))
      end
    end

    context 'nothing to #show' do
      before {netflix.pay(25)}
      subject {netflix.show(title: 'Not Found')}
      it 'raise exception if no movie' do
        expect {subject}.to raise_error(Theaters::MovieSearchError, "No results for '{:title=>\"Not Found\"}'")
                                .and avoid_changing(netflix, :balance)
      end

    end

    context 'with multiple search results' do
      before {netflix.pay(25)}
      subject {netflix.show(genre: 'Comedy')}
      it 'shows random movie' do
        expect(subject).to match(/^Now showing: Roman Holiday/)
                               .and include('Roman Holiday')
                                        .or include('Roman Holiday (new)')
      end
      it 'changes balance on ticket price amount' do
        expect {subject}.to change {netflix.balance}.from(Money.from_amount(25)).to(Money.from_amount(21))
      end
    end

    context 'with empty filter' do
      before {netflix.pay(25)}
      subject {netflix.show}
      it 'shows random movie' do
        expect(subject).to match(/^Now showing: Roman Holiday/)
                               .and include('Roman Holiday')
                                        .or include('Roman Holiday (new)')
      end
      it 'changes balance on ticket price amount' do
        expect {subject}.to change {netflix.balance}.from(Money.from_amount(25)).to(Money.from_amount(21))
      end
    end
  end
end

