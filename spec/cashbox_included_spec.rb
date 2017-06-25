module Cinematic
  describe Cashbox do

    let(:class_with_included_cashbox) {
      class WithIncludedCashbox
        include Cashbox
      end

    }
    let(:i_include_cashbox) {class_with_included_cashbox.new}
    let(:i_include_cashbox_too) {class_with_included_cashbox.new}
    let(:usd_25) {Money.from_amount(25, :USD)}
    let(:minus_usd_25) {Money.from_amount(-25, :USD)}

    context 'Cashbox amount' do
      context '#cash (alias #money)' do
        let(:old_balance) {i_include_cashbox.cash}
        context 'when cashbox init' do
          it '#cash (#money) returns 0 money in cashbox' do
            expect(i_include_cashbox.cash).to eq(0).and eq(i_include_cashbox.money)
          end
        end
        context 'when add money' do
          subject {i_include_cashbox.add_balance(usd_25)}
          it 'increase amount in exact instance cashbox' do
            expect {subject}.to change(i_include_cashbox, :cash).from(old_balance).to(old_balance + usd_25)
                                    .and change(i_include_cashbox, :money).from(old_balance).to(old_balance + usd_25)
                                             .and avoid_changing(i_include_cashbox_too, :cash)
                                                      .and avoid_changing(i_include_cashbox_too, :money)
          end
        end
        context 'when subtruct money' do
          subject {i_include_cashbox.subtract_balance(usd_25)}
          it 'decrease amount in exact instance cashbox' do
            expect {subject}.to change(i_include_cashbox, :cash).from(old_balance).to(old_balance - usd_25)
                                    .and change(i_include_cashbox, :money).from(old_balance).to(old_balance - usd_25)
                                             .and avoid_changing(i_include_cashbox_too, :cash)
                                                      .and avoid_changing(i_include_cashbox_too, :money)
          end

        end

        it 'has NO common cashbox #cash method' do
          expect {class_with_included_cashbox.cash}.to raise_exception(NoMethodError)
        end
      end
    end


    context 'Encashment' do
      context '#take' do
        let(:old_balance) {i_include_cashbox.cash}
        subject {i_include_cashbox.take(who)}

        context 'when empty cashbox' do
          context 'when taken by Bank' do
            let(:who) {'Bank'}
            it 'cash balance still 0' do
              expect {subject}.to_not change(i_include_cashbox, :cash).from(0)
            end
          end
          context 'when taken by unauthorized' do
            let(:who) {'not bank'}
            it 'raise exception' do
              expect {subject}.to raise_error(Cashbox::EncashmentError, 'Вызывает полицию')
                                      .and avoid_changing(i_include_cashbox, :cash)
                                               .and avoid_changing(i_include_cashbox, :money)
            end
          end

        end

        context 'when NOT empty cashbox' do
          before {i_include_cashbox.add_balance(usd_25)}
          context 'when taken by Bank' do
            let(:who) {'Bank'}
            it 'reset cashbox balance to 0' do
              expect {subject}.to change(i_include_cashbox, :cash).from(old_balance).to(0)
                                      .and change(i_include_cashbox, :money).from(old_balance).to(0)
            end
          end

          context 'when taken by unauthorized' do
            let(:who) {'not bank'}
            it 'raise exception' do
              expect {subject}.to raise_error(Cashbox::EncashmentError, 'Вызывает полицию')
                                      .and avoid_changing(i_include_cashbox, :cash)
                                               .and avoid_changing(i_include_cashbox, :money)
            end
          end
        end


      end
    end


    context '#add_balance' do
      context 'when negative amount' do
        subject {i_include_cashbox.add_balance(minus_usd_25)}
        it 'not change cashbox balance' do
          expect {subject}.to avoid_changing(i_include_cashbox, :cash)
                                  .and avoid_changing(i_include_cashbox, :money)
        end
      end
    end
    context '#subtract_balance' do
      context 'when negative amount' do
        subject {i_include_cashbox.subtract_balance(minus_usd_25)}
        it 'not change cashbox balance' do
          expect {subject}.to avoid_changing(i_include_cashbox, :cash)
                                  .and avoid_changing(i_include_cashbox, :money)
        end
      end
    end
  end
end



