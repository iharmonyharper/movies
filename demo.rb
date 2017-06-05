require_relative 'movie'
require_relative 'movie_collection'
require_relative 'csv_to_hash_converter'

HEADERS = %i{link name year country date genre duration rating director actors}
data = CsvToHashConverter.new(file_name: 'movies.txt', headers: HEADERS).data
movies = MovieCollection.new(collection_raw_data: data)

puts movies.all.first(5)
puts movies.sort_by(:date).first(5)
puts movies.filter(genre: 'Comedy', country: 'Italy')
puts movies.filter(genre: ['Comedy', 'Drama'], country: 'Italy')
puts movies.filter(rating: 9.1..9.2)
puts movies.all.first.actors
puts movies.stats(:premier_month)
puts movies.stats(:actors)