module Cinematic
  describe Theaters::Netflix do
    let(:old_romance_comedy) {{title: 'Roman Holiday', year: 1953, genre: 'Comedy,Romance', ticket_price: 4, rating: 8.2, duration: 90, actors: 'Gregory Peck,Audrey Hepburn,Eddie Albert'}}
    let(:new_drama_comedy) {{title: 'Roman Holiday (new)', year: 2000, genre: 'Comedy,Drama', ticket_price: 4, rating: 8.2, duration: 120, actors: ''}}
    let(:collection) {MovieCollection.new(title: 'TestCollection', collection_raw_data: [old_romance_comedy, new_drama_comedy], movie_class: Movies::Movie)}
    let(:netflix) {Netflix.new(movies_collection: collection)}
    let(:netflix_new) {Netflix.new(movies_collection: collection)}
    let(:usd_25) {Money.from_amount(25, :USD)}
    let(:usd_21) {Money.from_amount(21, :USD)}

    context '#pay' do
      let(:old_balance) {Netflix.cash}
      let(:old_instance_balance) {netflix.balance}
      subject {netflix.pay(usd_25)}
      it 'changes instance balance if payment' do
        expect {subject}.to change {netflix.balance}.from(old_instance_balance).to(old_instance_balance + usd_25)
      end

      it 'changes common cashbox balance if payment' do
        expect {subject}.to change {Netflix.cash}.from(old_balance)
                                .to(old_balance + usd_25)
      end


      context 'not enough money to #pay' do
        subject {netflix.show(title: 'Roman Holiday')}
        it 'raise exception if not enough money' do
          expect {subject}.to raise_error(Netflix::AccountBalanceError, 'Not enough balance for Theaters::Netflix')
                                  .and avoid_changing(netflix, :balance)
                                           .and avoid_changing(Netflix, :cash)
        end
      end
    end

    context '#show with 1 search result' do
      before {netflix.pay(usd_25)}
      subject {netflix.show(genre: 'Romance', period: :classic)}
      it 'shows movie' do
        expect(subject).to eq("Now showing: Roman Holiday #{Time.now.strftime('%H:%M')} - #{(Time.now + (90 * 60)).strftime('%H:%M')}")
      end
      it 'changes balance on ticket price amount' do
        expect {subject}.to change {netflix.balance}.from(Money.from_amount(25)).to(Money.from_amount(21))
                                .and avoid_changing(Netflix, :money)
      end
    end

    context 'nothing to #show' do
      before {netflix.pay(usd_25)}
      subject {netflix.show(title: 'Not Found')}
      it 'raise exception if no movie' do
        expect {subject}.to raise_error(Theaters::MovieSearchError, "No results for '{:title=>\"Not Found\"}'")
                                .and avoid_changing(netflix, :balance)
      end

    end

    context 'with multiple search results' do
      before {netflix.pay(usd_25)}
      subject {netflix.show(genre: 'Comedy')}
      it 'shows random movie' do
        expect(subject).to match(/^Now showing: Roman Holiday/)
                               .and include('Roman Holiday')
                                        .or include('Roman Holiday (new)')
      end
      it 'changes balance on ticket price amount' do
        expect {subject}.to change {netflix.balance}.from(usd_25).to(usd_21)
      end
    end

    context 'with empty filter' do
      before {netflix.pay(usd_25)}
      subject {netflix.show}
      it 'shows random movie' do
        expect(subject).to match(/^Now showing: Roman Holiday/)
                               .and include('Roman Holiday')
                                        .or include('Roman Holiday (new)')
      end
      it 'changes balance on ticket price amount' do
        expect {subject}.to change {netflix.balance}.from(usd_25).to(usd_21)
      end
    end

    context '#take' do
      before {
        netflix_new.pay(usd_25)
      }
      let(:old_balance) {Netflix.cash}
      subject {Netflix.take(who)}
      context 'when taken by Bank' do
        let(:who) {'Bank'}
        it 'reset cashbox balance to 0' do
          expect {subject}.to change {Netflix.cash}.from(old_balance).to(0)
        end
      end

      context 'when taken by unauthorized' do
        let(:who) {'not bank'}
        it 'raise exception' do
          expect {subject}.to raise_error(Cashbox::EncashmentError, 'Вызывает полицию').and avoid_changing(Netflix, :cash)
        end
      end
    end
  end
end

