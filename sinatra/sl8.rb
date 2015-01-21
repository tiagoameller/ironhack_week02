# SL8. The smallest IMDB web application ever

# Remember IMDB gem? Oh, it feels like last year since we used it. Shall we do it again? YES!

# Re-using some knowledge we already have on it, we will implement a small Sinatra web app that performs the following:
# 1. GET '/top250' lists the Top 250 movies titles. If a "limit" parameter is set, then we limit the list to first "limit" results.
# 2. GET '/rating' will get the rating for a specific movie or TV show. If "id" is passed, we will use this "id" directly to fetch
# the movie or show. If "title" is passed instead, we will search for that title and get the first result. Also, if the rating is lower than 5,
# we will go to a '/warning' page directly, advising of the dangers of watching that movie/show.
# 3. GET '/info' will get all the information for a specific movie or TV show: title, year of release, cast members... you title it.
# Again, we will use "id" or "title" params to fetch it.
# 4. GET '/results' will get a "term" parameter, and will return the number of results for a search using that term.
# 5. GET '/now' will print the current date and time. Because sometimes it's useful.

require 'pstore'
require 'ap'
require 'sinatra'
set :port, 3001
set :bind, '0.0.0.0'

class Movie < Struct.new(:id,:title,:rating,:year)

  def to_s
    "IMDB ID: #{id}. #{title}. Rating: #{rating}. Year: #{year}"
  end
end

class SL8
  attr_reader :movies

  def initialize
    @movies_pstore = PStore.new("movies_250.pstore")
    @movies = {}
    load_movies_pstore

    # @movies.values.each do |movie|
    #   ap movie.to_s
    # end
  end

  private

    def load_movies_pstore
    @movies_pstore.transaction do
      @movies_pstore.roots.each do |item|
        @movies[item] = Movie.new(
          item,
          @movies_pstore[item][1].gsub(/\d{1,3}\.\n\s+/,""),
          @movies_pstore[item][2],
          @movies_pstore[item][3])
      end
      @movies_pstore.commit
    end
  end
end


### main
sl8 = SL8.new

get '/top' do
  @movies = sl8.movies.values
  @limit = params[:limit] ||= 250
  erb :sl8_top
end
