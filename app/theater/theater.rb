require_relative 'base_theater'

class Theater < BaseTheater
  FILTERS = { morning: { period: :ancient, genre: /^((?!drama|horror).)/i },
              day: { period: /^((?!:ancient).)/i, genre: /(comedy)|(adventure)/i, genre: /^((?!drama|comedy).)/i },
              evening: { genre: /(drama)|(horror)/i } }.freeze

  def when?(movie_title)
    movie = movies_collection.filter(title: movie_title)[0]
    if %w[Drama Horror].any? { |genre| movie.genre.include? genre }
      :evening
    elsif movie.period == :ancient
      :morning
    elsif %w[Comedy Adventure].any? { |genre| movie.genre.include? genre }
      :day
    else
      :never
    end
  end

  def filters(time)
    FILTERS[time]
  end

  def show(time)
    super(nil, filters(time))
  end
end
