require 'date'
require 'json'

class ClassicMovie < Movie
  def initialize(movies_collection: [], **args)
    super(movies_collection: movies_collection, **args)
    @period = :classic
    @ticket_price = 1.50
  end

  def to_s
    "#{@title} — классический фильм, режиссёр #{@director} (#{@movies_collection.filter(director: @director).map(&:title).join(',')})"
  end
end
