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

    def show(**filter, &block)
      filter, block = get_filter(**filter, &block)
      movie_to_show = find_movies_to_show(filter, &block)
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

    def get_filter(**filter, &block)
      custom, default = split_filter(**filter)
      return [filter, block] if custom.empty?

      custom_filter, custom_proc = split_custom_filter(filter)
      filter = merge_filters(default, custom_filter)
      _f_name, f_value = custom.first
      unless custom_proc.empty?
        block = merge_blocks(custom_proc: custom_proc,
                             filter_value: f_value,
                             &block)
      end

      [filter, block]
    end

    def split_filter(**filter)
      filter.partition { |k, _v| custom_filters.keys.include?(k) if custom_filters }
    end

    def split_custom_filter(**filter)
      filters = custom_filters.select { |k, _v| filter.keys.include?(k) && filter[k] }.values
      filters.partition { |c| c.arity.zero? }
    end

    def merge_filters(default, custom)
      default.to_h.merge(custom.map(&:call).inject(&:merge).to_h)
    end

    def merge_blocks(custom_proc:, filter_value:)
      return proc { |x| yield(x) && custom_proc.first.call(x, filter_value) } if block_given?
      proc { |x| custom_proc.first.call(x, filter_value) }
    end
  end
end
