require_relative 'base_theater'

class Theater < BaseTheater
  attr_accessor :schedule, :filters

  FILTERS = {  morning: { period: :ancient },
               day:     { genres: /(comedy)|(adventure)/i },
               evening: { genres: /(drama)|(horror)/i } }.freeze

  SCHEDULE = { morning: ('09:00'...'14:00'),
               day:     ('14:00'...'19:00'),
               evening: ('19:00'...'23:00') }.freeze

  def when?(movie_title)
    movie = movies_collection.filter(title: movie_title).first
    return 'Not found' unless movie
    time, = filters.detect { |_, filter| movie.matches?(**filter)}
    return 'Not found' unless time
    schedule[time].first
  end

  def start_time(movie)
    Time.parse(when?(movie.title))
  end

  def filters
    @filters || FILTERS
  end

  def schedule
    @schedule || SCHEDULE
  end

  def show(time)
    t, = schedule.detect {|_time, time_range| time_range.cover? time }
    return 'No movies for this time' unless t
    super(nil, **filters[t])
  end
end
