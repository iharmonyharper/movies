require 'date'
require 'json'

class NewMovie < Movie
  def initialize(movies_collection: [], **args)
    super(movies_collection: movies_collection, **args)
    @period = :new
    @ticket_price = 5.00
  end

  def to_s
    "#{@title} — новинка, вышло #{Time.now.year - @year} лет назад!"
  end
end
