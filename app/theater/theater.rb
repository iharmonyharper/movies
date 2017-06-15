require_relative 'base_theater'

class Theater < BaseTheater
  attr_accessor :schedule

  NOT_DRAMA_HORROR_REGEX = /^(?!.*(drama|horror)).*$/i
  NOT_ANCIENT_REGEX = /^(?!.*(ancient)).*$/i

  FILTERS = { morning: { period: :ancient, genres: NOT_DRAMA_HORROR_REGEX },
              day: { period: NOT_ANCIENT_REGEX , genres: NOT_DRAMA_HORROR_REGEX, genre: /(comedy)|(adventure)/i  },
              evening: { genres: /(drama)|(horror)/i } }

  SCHEDULE = { morning: ['09:00', '14:00'] ,
    day:  ['14:00', '19:00'] ,
    evening:  ['19:00', '23:00'] }


  def when?(movie_title)
    t = time_filters.detect{|(time, filter)|
      movie = movies_collection.filter({title: movie_title}.merge(filter))
      time unless movie.empty?
    }
    t ? schedule[t.first].join(' - ') : 'Not found'
  end

  def schedule
    @schedule ||= SCHEDULE

  end

  def time_filters
    FILTERS
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
