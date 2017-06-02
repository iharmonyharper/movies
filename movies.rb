require 'csv'

HEADERS = [:link, :name, :year, :country, :premier, :genre, :duration, :rating, :director, :stars]

filename, keyword = ARGV if ARGV.count > 1
keyword, filename = ARGV if ARGV.count < 2

file = filename || 'movies.txt'
raise "File '#{file}' is not found" unless File.exist?(file)

movies = CSV.read(file, :col_sep => '|').map {|movie| HEADERS.zip(movie).to_h}

def filter(movies, keyword)
  movies.select {|movie| movie[:name][/#{keyword}/]}
end

def rating(rating_float)
  asterisk_number = ((rating_float.to_f - 8.0).round(1) * 10)
  asterisk_number > 0 ? '*' * asterisk_number : '*'
end

def pretty_print(movies)
  puts movies.map {|m| "#{rating m[:rating]}; #{m[:name]} (#{m[:premier]}; #{m[:genre]}) - #{m[:duration]}"}
end

pretty_print(movies.sort_by {|m| m[:duration].to_i}.last(5))
pretty_print(movies.select {|m| m[:genre][/^comedy$/i]}.sort_by {|m| m[:duration].to_i})
puts (movies.sort_by {|m| m[:director].split(' ').last}).map {|m| m[:director]}
puts movies.reject {|m| m[:country][/^usa$/i]}.count