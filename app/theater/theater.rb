require_relative 'base_theater'

class Theater < BaseTheater
  def when?(movie_title)
    movie = movies_collection.filter(title: movie_title)[0]
    if %w[Drama Horror].any? { |genre| movie.genre.include? genre }
      'evening'
    elsif movie.period == :ancient
      'morning'
    elsif %w[Comedy Adventure].any? { |genre| movie.genre.include? genre }
      'day'
    else
      'never'
    end
  end

  def show(time)
    filter(time)
    super(nil, filter(time))
  end

  def filter(time)
    case time
    when 'morning'
      { period: :ancient, genre: /^((?!drama|horror).)/i }
    when 'day'
      { period: /^((?!:ancient).)/i, genre: /(comedy)|(adventure)/i, genre: /^((?!drama|comedy).)/i }
    when 'evening'
      { genre: /(drama)|(horror)/i }
    end
  end
end
