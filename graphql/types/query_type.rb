require 'rubicure'

module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :girl, Types::MemberType, null: false, description: "Get a Precure", deprecation_reason: "Cure Wing is a boy." do
      argument :girl_name, String, required: true, description: "Precure's symbol"
    end
    def girl(girl_name:)
      find_member(girl_name)
    end

    field :member, Types::MemberType, null: false, description: "Get a Precure" do
      argument :member_name, String, required: true, description: "Precure's symbol"
    end
    def member(member_name:)
      find_member(member_name)
    end

    field :movie, Types::MovieType, null: false, description: "Get information about a movie" do
      argument :movie_name, String, required: true, description: "Movie's symbol"
    end
    def movie(movie_name:)
      find_movie(movie_name)
    end

    field :all_movies, [Types::MovieType], null: false, description: "Get all movies"
    def all_movies
      Rubicure::Movie.uniq_names.map do |name|
        Rubicure::Movie.find(name)
      end
    end

    def self.define_cure(name)
      define_method(name) {
        Rubicure::Girl.find(name)
      }
    end

    Precure.all_girls.map(&:girl_name).each do |girl|
      field girl.intern, Types::MemberType, null: false
      # define method dynamically
      define_cure girl.intern
    end

    field :series, Types::SeriesType, null: false, description: "Get information about series" do
      argument :series_name, String, required: true, description: "Series symbol"
    end
    def series(series_name:)
      name = series_name.intern
      return now if %i[now current].include?(name)
      # Never pass the argument to Precure.send: it would call any method, e.g. "exit".
      raise GraphQL::ExecutionError, "unknown series: #{series_name}" unless Rubicure::Series.valid?(name)
      Rubicure::Series.find(name)
    end

    field :precure_all_stars, [Types::MemberType], null: false, description: "Get Precure All Stars" do
      argument :series, String, required: false, description: "Prescribe which series from Precure All Stars(if absent, prescribes 'Futari wa Pretty Cure' to 'Maho Girls Precure')"
    end
    def precure_all_stars(series: nil)
      return Precure.all_stars unless series.present?
      find_movie(series)
      Precure.all_stars(series.intern)
    end

    field :precure_dream_stars, [Types::MemberType], null: false, description: "Get Precure seen in 'Precure Dream Stars'"
    def precure_dream_stars
      Precure.dream_stars
    end

    field :precure_super_stars, [Types::MemberType], null: false, description: "Get Precure seen in 'Precure Super Stars'"
    def precure_super_stars
      Precure.super_stars
    end

    field :precure_miracle_leap, [Types::MemberType], null: false, description: "Get Precure seen in 'Precure Miracle Leap'"
    def precure_miracle_leap
      Precure.miracle_leap
    end

    field :precure_all_girls, [Types::MemberType], null: false, description: "Get all Precure", deprecation_reason: "Cure Wing is a boy."
    def precure_all_girls
      precure_all
    end

    field :precure_all, [Types::MemberType], null: false, description: "Get all Precure"
    def precure_all
      Precure.all
    end

    field :all_series, [Types::SeriesType], null: false, description: "Get all series"
    def all_series
      Precure
    end

    field :colors, [Types::ColorType], null: false, description: "Get colors and members"
    def colors
      Rubicure::Girl.colors
    end

    field :color, Types::ColorType, null: false, description: "Get color and members specified color" do
      argument :color, String, required: true, description: "Specified color"
    end
    def color(color:)
      raise GraphQL::ExecutionError, "unknown color: #{color}" unless Rubicure::Girl.colors.include?(color.intern)
      color.intern
    end

    field :now, Types::SeriesType, null: false, description: "Get now on air series"
    def now
      Precure.now
    rescue Rubicure::NotOnAirError => e
      raise GraphQL::ExecutionError, e.message
    end

    field :current, Types::SeriesType, null: false, description: "Get now on air series"
    def current
      now
    end

    field :version, String, null: false
    def version
      '4.0.2.0'
    end

    private

    # A name that rubicure does not know is answered with a GraphQL error
    # instead of letting rubicure's exception escape as a 500.
    def find_member(name)
      raise GraphQL::ExecutionError, "unknown member: #{name}" unless Rubicure::Girl.valid?(name.intern)
      Rubicure::Girl.find(name.intern)
    end

    def find_movie(name)
      raise GraphQL::ExecutionError, "unknown movie: #{name}" unless Rubicure::Movie.valid?(name.intern)
      Rubicure::Movie.find(name.intern)
    end
  end
end
