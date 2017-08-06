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
        custom_filters[filter_name] = Proc.new{ |x| custom_filters[from].call(x, arg) } if arg
      else
        custom_filters[filter_name] = block if block_given?
      end
    end

    def show(**filter, &block)
      customer, default = filter.partition do |k, _v|
        custom_filters.keys.include?(k) if custom_filters
      end
      unless customer.empty?
        custom = custom_filters.select { |k, _v| filter.keys.include?(k) && filter[k] }.values
        custom_f, custom_proc = custom.partition { |c| c.arity == 0 } if custom
        filter = default.to_h.merge(custom_f.map(&:call).inject(&:merge).to_h)
        unless custom_proc.empty?
          f_name, f_value = customer.first
          block = proc { |x| custom_proc.first.call(x, f_value) } unless block_given?
          block = proc { |x| block.call(x) && custom_proc.first.call(x, f_value) } if block_given?
        end
      end

      movie_to_show = find_movies_to_show(filter, &block)
      withdraw(movie_to_show.ticket_price)
      super(movie = movie_to_show)
    end

    def start_time(_movie)
      Time.now
    end

    def pay(amount)
      amount = Money.from_amount(amount) unless Money === amount
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
  end
end
