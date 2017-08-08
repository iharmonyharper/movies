module Theaters
  class Netflix < BaseTheater
    attr_reader :balance, :custom_filters

    def initialize(movies_collection: [])
      super
      @balance = Money.from_amount(0)
    end

    def define_filter(filter_name, from: nil, arg: nil, &block)
      if from
        custom_filters[filter_name] = custom_filters[from]
        custom_filters[filter_name] = proc { |x| custom_filters[from].call(x, arg) } if arg
      elsif block_given?
        custom_filters[filter_name] = block
      end
    end

    # def show(**filter, &block)
    #   filter, block = get_filter(**filter, &block)
    #   movie_to_show = find_movies_to_show(filter, &block)
    #   withdraw(movie_to_show.ticket_price)
    #   super(movie_to_show)
    # end

    def show(**filter, &block)
      result = filter_collection(filter, &block)
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

    def custom_filters
      @custom_filters ||= {}
    end

    def filter_collection(**filter, &block)
      custom, default = filter.partition { |k, _v| custom_filters.keys.include?(k) }.map(&:to_h)
      filter = default
      result = movies_collection.filter(filter, &block)
      custom.inject(result) do |res, (name, arg)|
        if custom_filters[name].arity.zero?
          filter = custom_filters[name].call
        else
          block = proc { |x| custom_filters[name].call(x, arg) }
        end
        res.select(&block).select { |m| m.matches? filter }
      end
    end
  end
end
