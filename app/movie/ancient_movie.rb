require 'date'
require 'json'

class AncientMovie < Movie
  def initialize(movies_collection: [], **args)
    super(movies_collection: movies_collection, **args)
    @period = :ancient
    @ticket_price = 1.00
  end

  def to_s
    "#{@title} — старый фильм (#{@year} год)"
  end
end
