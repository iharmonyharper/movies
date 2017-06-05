require 'date'


class MovieCollection
  attr_reader :collection

  def initialize(args = {})
    @collection_raw_data = args.fetch(:collection_raw_data, [])
    @movie_class = args.fetch(:movie_class, Movie)
    @collection = @collection_raw_data.map {|data| @movie_class.new(data)}
  end

  def all
    collection
  end

  def sort_by(*fields)
    sorted = all
    fields.each do |field|
      sorted = sorted.sort_by {|m| m.send(field).to_s}
    end
    sorted
  end

  def filter(**fields)
    filtered = all
    fields.each do |k, v|
      filtered = filtered.select do |m|
        case v
          when Range
            v.include? m.send(k).to_f.round(2)
          else
            _keywords = Array[*v]
            _values = Array[*m.send(k)]
            _values.join(',').include? _keywords.join(',')
        end
      end
    end
    filtered
  end

  def stats(field)
    case field
      when :premier_month
        statistics(field).map {|k, v| [Date::MONTHNAMES[k], v.count]}.to_h
      else
        statistics(field).map {|k, v| [k, v.count]}.to_h
    end
  end

  private
  def statistics(field)
    all.map {|m| m.send(field) rescue nil}.flatten
        .compact
        .group_by(&:itself)
        .sort_by(&:first)
  end

end


