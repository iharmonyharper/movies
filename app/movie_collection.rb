require 'date'

class MovieCollection
  attr_reader :title, :collection, :collection_raw_data

  def initialize(title: 'new_collection', collection_raw_data: [], movie_class: Movie)
    @collection_raw_data = collection_raw_data
    @movie_class = movie_class
    @title = title
    @collection = get_movies
  end

  def all
    @collection
  end

  def get_movies
    @collection_raw_data.map do |data|
      case data[:year].to_i
      when (1900...1945)
        @movie_class = AncientMovie
      when (1945...1968)
        @movie_class = ClassicMovie
      when (1968...2000)
        @movie_class = ModernMovie
      when (2000...2100)
        @movie_class = NewMovie
      end
      @movie_class.new(movies_collection: self, **data)
    end
  end

  def genres
    @collection.map(&:genre).uniq
  end

  def sort_by(*fields)
    all.sort_by { |m|  fields.map { |f| m.send(f) } }
  end

  def filter(**fields)
    fields.reduce(all) do |filtered, (k, v)|
      filtered.select do |m|
        (v.is_a?(Range) ? Array[v] : Array[*v]).all? do |value|
          Array[*m.send(k)].any? do |item|
            value === item
          end
        end
      end
    end
  end

  def stats(field: :premier_month, param: :count)
    case field
    when :premier_month
      statistics(field).map { |k, v| [Date::MONTHNAMES[k], param ? v.send(param) : v] }.to_h
    else
      statistics(field).map { |k, v| [k, param ? v.send(param) : v] }.to_h
    end
  end

  private

  def statistics(field)
    all.map do |m|
      begin
                   m.send(field)
                 rescue
                   nil
                 end
    end.flatten
       .compact
       .group_by(&:itself)
       .sort_by(&:first)
  end
end
