require_relative 'base_theater'

class Theater < BaseTheater
  attr_accessor :schedule, :filters

  FILTERS = {  morning: { period: :ancient },
               evening: { genres: /(drama)|(horror)/i },
               day:     { genres: /(comedy)|(adventure)/i } }.freeze

  SCHEDULE = { morning: ('09:00'..'14:00'),
               day:     ('14:00'..'19:00'),
               evening: ('19:00'..'23:00') }.freeze

  def when?(movie_title)
    movie = movies_collection.filter(title: movie_title).first
    return 'Not found' unless movie
    time, = filters.detect do |_, filter|
      movie.matches?(**filter)
    end
    return 'Not found' unless time
    schedule[time].first
  end

  def filters
    @filters || FILTERS
  end

  def schedule
    @schedule || SCHEDULE
  end

  def show(time)
    t, = schedule.detect do |_time, time_range|
      begin
        time_range.cover? time
      rescue
        nil
      end
    end
    return 'No movies for this time' unless t
    super(nil, **filters[t])
  end
end
