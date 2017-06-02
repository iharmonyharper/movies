require 'csv'

HEADERS = [:link, :name, :year, :country, :premier, :genre, :duration, :rating, :director, :stars]

filename, keyword = ARGV if ARGV.count > 1
keyword, filename = ARGV if ARGV.count < 2

file = filename || 'movies.txt'
raise "File '#{file}' is not found" unless File.exist?(file)

movies = CSV.read(file, :col_sep => '|').map {|movie| Hash[HEADERS.zip(movie)]}

def filter(movies, keyword)
  movies.select {|movie| movie[:name][/#{keyword}/]}.map {|movie| "#{movie[:name]}, #{rating(movie[:rating])}"}
end

def rating(rating_float)
  '*' * ((rating_float.to_f - 8.0).round(1) * 10)
end

puts filter(movies, keyword)
