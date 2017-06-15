require_relative 'base_theater'

class Theater < BaseTheater
  attr_accessor :schedule

  NOT_DRAMA_HORROR_REGEX = /^(?!.*(drama|horror)).*$/i
  NOT_ANCIENT_REGEX = /^(?!.*(ancient)).*$/i

  FILTERS = { morning: { period: :ancient, genres: NOT_DRAMA_HORROR_REGEX },
              day: { period: NOT_ANCIENT_REGEX , genres: NOT_DRAMA_HORROR_REGEX, genre: /(comedy)|(adventure)/i  },
              evening: { genres: /(drama)|(horror)/i } }.freeze

  SCHEDULE = { morning: ['09:00', '14:00'] ,
    day:  ['14:00', '19:00'] ,
    evening:  ['19:00', '23:00'] }


  def when?(movie_title)
    movie = movies_collection.filter(title: movie_title)
    if %w[Drama Horror].any? { |genre| movie.genre.include? genre }
      schedule[:evening].join(' - ')
    elsif movie.period == :ancient
      schedule[:morning].join(' - ')
    elsif %w[Comedy Adventure].any? { |genre| movie.genre.include? genre }
      schedule[:day].join(' - ')
    else
      'Not found'
    end
  end

  def schedule
    @schedule ||= SCHEDULE

  end

  def filters(time)
    FILTERS[time]
  end

  def show(time)
    t = schedule.select{|k,v| v[0] == time }.keys.first
    if t
      super(nil,   **filters(t))
    else
      'No movies for this time'
    end

  end
end
