require 'date'
require 'json'

class ModernMovie < Movie
  def initialize(movies_collection: [], **args)
    super(movies_collection: movies_collection, **args)
    @period = :modern
    @ticket_price = 3.00
  end

  def to_s
    "#{@title} — современное кино: играют #{@actors}"
  end
end
