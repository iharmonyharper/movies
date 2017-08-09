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
        expect {subject}.to raise_error(Theaters::MovieSearchError, 'No results for filter')
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

    context 'with custom filters' do
      let(:modern_sci_fi) {{title: 'The Terminator', year: 1984, genre: 'Action,Sci-Fi', ticket_price: 4, rating: 8.1, duration: 107, country: 'UK', director: 'James Cameron', actors: 'Arnold Schwarzenegger,Linda Hamilton,Michael Biehn'}}
      let(:new_modern_sci_fi) {{title: 'Terminator 2: Judgment Day', year: 1991, genre: 'Action,Sci-Fi', ticket_price: 4, rating: 8.1, duration: 107, country: 'USA', director: 'James Cameron', actors: 'Arnold Schwarzenegger,Linda Hamilton,Michael Biehn'}}
      let(:newest_modern_sci_fi) {{title: 'Mad Max: Fury Road', year: 2015, genre: 'Action,Adventure,Sci-Fi', ticket_price: 4, rating: 8.1, duration: 107, country: 'USA', director: 'George Miller', actors: 'Tom Hardy,Charlize Theron,Nicholas Houl'}}

      let(:collection) {MovieCollection.new(title: 'TestCollection',
                                            collection_raw_data: [old_romance_comedy,
                                                                  new_drama_comedy,
                                                                  modern_sci_fi,
                                                                  new_modern_sci_fi,
                                                                  newest_modern_sci_fi],
                                            movie_class: Movies::Movie)}

      before {netflix.pay(usd_25)}

      it 'should be a block' do
        netflix.define_filter(:new_sci_fi) {{genre: 'Sci-Fi', period: :modern}}
        expect(netflix.custom_filters[:new_sci_fi]).to be_a_kind_of(Proc)
      end

      it 'raises exception when not a block' do
        expect {netflix.define_filter(:new_sci_fi)}.to raise_error('Can`t define filter.')
      end

      context '#define custom filter simple' do
        it 'shows movie according to filter' do
          netflix.define_filter(:new_sci_fi) {{genre: 'Sci-Fi', period: :modern}}
          expect(netflix.show(new_sci_fi: true, title: /The/) {|movie| movie.director.include?('Cam')})
              .to match('Now showing: The Terminator ')
        end
      end

      context '#define custom filter with additional params' do
        it 'shows movie according to filters' do
          netflix.define_filter(:new_sci_fi) {|movie, year| movie.year > year && movie.genre.include?('Sci-Fi')}
          expect(netflix.show(new_sci_fi: 1985, actors: 'Arnold Schwarzenegger'))
              .to match('Now showing: Terminator 2: Judgment Day ')
        end
      end

      context '#define custom filter from another filter with additional parameter' do
        it 'shows movie according to filters' do
          netflix.define_filter(:new_sci_fi) {|movie, year| movie.year > year && movie.genre.include?('Sci-Fi')}
          netflix.define_filter(:newest_sci_fi, from: :new_sci_fi, arg: 2014)
          expect(netflix.show(newest_sci_fi: true))
              .to match('Now showing: Mad Max: Fury Road ')
        end
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




