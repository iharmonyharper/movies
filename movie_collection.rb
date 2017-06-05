require 'date'


class MovieCollection
  attr_reader :collection

  def initialize(collection_raw_data: [],
                 movie_class: Movie)
    @collection_raw_data = collection_raw_data
    @movie_class = movie_class
    @collection = @collection_raw_data.map {|data| @movie_class.new(data)}
  end

  def all
    collection
  end

  def sort_by(*fields)
      all.sort_by {|m|  fields.map{|f| m.send(f)} }
  end

  def filter(**fields)
    fields.reduce(filtered=all) do |filtered, (k, v)|
      filtered.select { |m|
        (v.is_a?(Range) ? Array[v] : Array[*v]).all?{|value|
          Array[*m.send(k)].any?{|item| (value === item) || (value === item.to_f.round(2))}
        }
      }
    end
  end

  def stats(field)
    case field
      when :premier_month
        statistics(field).map {|k, v| [Date::MONTHNAMES[k], v.count]}.to_h
      else
        statistics(field).map {|k, v| [k, v.count]}.to_h
        _values = nil  end
  end

  private
  def statistics(field)
    all.map {|m| m.send(field) rescue nil}.flatten
        .compact
        .group_by(&:itself)
        .sort_by(&:first)
  end

end


