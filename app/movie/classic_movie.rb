module Movies
class ClassicMovie < Movie
  def to_s
    "#{@title} — классический фильм, режиссёр #{@director} (#{@movies_collection.filter(director: @director).map(&:title).join(',')})"
  end
end
end