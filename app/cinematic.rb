require_relative 'cashbox'
require_relative 'movies'
require_relative 'theaters'
require_relative 'movie_collection'
require_relative '../helpers/csv_to_hash_converter'

module Cinematic
  include Cashbox
  include Movies
  include Theaters
end