module Cinematic
require 'date'

class MovieCollection
  attr_reader :title, :collection, :collection_raw_data

  include Enumerable

  def initialize(title: 'new_collection', collection_raw_data: [], movie_class:)
    @collection_raw_data = collection_raw_data
    @title = title
    @movie_class = movie_class
    @collection = get_movies
  end

  def all
    @collection
  end

  def get_movies
    @collection_raw_data.map do |data|
      @movie_class.build(movies_collection: self, data: data)
    end
  end

  def genres
    @collection.map(&:genre).uniq
  end

  def sort_by(*fields)
    all.sort_by { |m|  fields.map { |f| m.send(f) } }
  end

  def filter(**fields)
    reduce(all) do |filtered, _|
      filtered.select{ |m|
        m.matches?(fields)
      }
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

  def each(&block)
    @collection.each(&block)
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
end


