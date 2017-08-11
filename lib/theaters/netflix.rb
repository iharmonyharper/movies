module Theaters
  class Netflix < BaseTheater
    attr_reader :balance, :custom_filters

    def initialize(movies_collection: [])
      super
      @balance = Money.from_amount(0)
    end

    def custom_filters
      @custom_filters ||= {}
    end

    def define_filter(filter_name, from: nil, arg: nil, &block)
      custom_filters[filter_name] =
        if from && arg
          proc { |x| custom_filters[from].call(x, arg) }
        elsif block_given?
          block
        else
          raise 'Can`t define filter.'
        end
    end

    def show(**filter, &block)
      result = apply_filters(filter, &block)
      movie_to_show = random_movie(result)
      withdraw(movie_to_show.ticket_price)
      super(movie_to_show)
    end

    def start_time(_movie)
      Time.now
    end

    def pay(amount)
      amount = Money.from_amount(amount) unless amount.is_a?(Money)
      raise(PaymentError, 'Invalid payment operation') if amount.negative?
      @balance += amount
      Netflix.add_balance(amount)
    end

    class AccountBalanceError < StandardError
    end
    class PaymentError < StandardError
    end

    private

    def withdraw(amount)
      amount = Money.from_amount(amount)
      raise(AccountBalanceError, "Not enough balance for #{self.class}") if (@balance - amount).negative?
      @balance -= amount
    end

    def apply_filters(**filter, &block)
      custom, default = filter.partition { |k, _v| custom_filters.keys.include?(k) }.map(&:to_h)
      result = movies_collection.filter(default, &block)
      custom.inject(result) do |res, (name, arg)|
        filter = custom_filters[name]
        res.select { |m| filter.call(m, arg) }
      end
    end
  end
end
