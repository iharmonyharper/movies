require 'csv'
require 'ostruct'
require 'date'

HEADERS = %i{link name year country premier genre duration rating director stars}

filename, keyword = ARGV if ARGV.count > 1
keyword, filename = ARGV if ARGV.count < 2

file = filename || 'movies.txt'
raise "File '#{file}' is not found" unless File.exist?(file)

movies = CSV.read(file, headers: HEADERS, col_sep: '|').map {|movie|
  OpenStruct.new(movie.to_h)
}

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

pretty_print(movies.sort_by {|m| m.duration.to_i}.last(5).uniq)
pretty_print(movies.select {|m| m.genre.include? 'Comedy'}.sort_by {|m| m.duration.to_i}.uniq)
puts (movies.map(&:director).sort_by {|name| name.split(' ').last}).uniq
puts movies.count {|m| !m.country.include? 'USA'}

puts statistics = movies.map {|m| Date.strptime(m.premier, '%Y-%m').mon rescue nil}
                      .compact
                      .group_by(&:itself)
                      .sort_by(&:first)
                      .map {|k, v| [Date::MONTHNAMES[k], v.count]}.to_h
