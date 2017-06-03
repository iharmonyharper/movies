require 'csv'
require 'ostruct'
require 'date'

HEADERS = [:link, :name, :year, :country, :premier, :genre, :duration, :rating, :director, :stars]

filename, keyword = ARGV if ARGV.count > 1
keyword, filename = ARGV if ARGV.count < 2

file = filename || 'movies.txt'
raise "File '#{file}' is not found" unless File.exist?(file)

movies = CSV.read(file, :col_sep => '|').map {|movie| OpenStruct.new(HEADERS.zip(movie).to_h)}

def filter(movies, keyword)
  movies.select {|movie| movie.name[/#{keyword}/]}
end

def rating(rating_float)
  asterisk_number = ((rating_float.to_f - 8.0).round(1) * 10)
  asterisk_number > 0 ? '*' * asterisk_number : '*'
end

def pretty_print(movies)
  puts movies.map {|m| "#{rating m.rating}; #{m.name} (#{m.premier}; #{m.genre}) - #{m.duration}"}
end

pretty_print(movies.sort_by {|m| m.duration.to_i}.last(5))
pretty_print(movies.select {|m| m.genre.include? 'Comedy'}.sort_by {|m| m.duration.to_i})
puts (movies.map(&:director).sort_by {|name| name.split(' ').last})
puts movies.count {|m| !m.country.include? 'USA'}

puts statistics = movies.group_by {|m|
  Date.strptime(m.premier, '%Y-%m').mon rescue 'Invalid date'}
                 .reject {|k, v| k == 'Invalid date'}
                 .sort_by {|k, v| k}
                 .map {|k, v| [Date::MONTHNAMES[k], v.count]
}.to_h
