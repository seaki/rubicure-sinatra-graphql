require File.expand_path '../../spec_helper.rb', __FILE__

RSpec.describe Schema do
  def execute(query_string)
    post '/graphql', { "query" => query_string }
    JSON.parse(last_response.body)
  end

  # Selects every field of the type. Fields returning objects are followed down to `depth` levels,
  # so a field added to a type later is covered without touching this spec.
  def selection(type, depth = 2)
    type.fields.map do |name, field|
      inner = field.type.unwrap
      next name unless inner.kind.object?
      "#{name} { #{selection(inner, depth - 1)} }" if depth > 0
    end.compact.join(" ")
  end

  def camelize(name)
    name.to_s.gsub(/_(.)/) { $1.upcase }
  end

  # rubicure's data grows with every release (and differs between the ruby-* branches),
  # so everything it knows is resolved here instead of a hand-picked sample.
  describe "every field resolves without an error" do
    Precure.all_girls.map(&:girl_name).each do |girl_name|
      it "for member #{girl_name}" do
        field = camelize(girl_name)
        res = execute("{ #{field} { #{selection(Types::MemberType)} } }")
        expect(res["errors"]).to be_nil
        expect(res["data"][field]["memberName"]).to eq girl_name
      end
    end

    Rubicure::Series.uniq_names.each do |series_name|
      it "for series #{series_name}" do
        res = execute(%({ series(seriesName: "#{series_name}") { #{selection(Types::SeriesType)} } }))
        expect(res["errors"]).to be_nil
        expect(res["data"]["series"]["title"]).to eq Rubicure::Series.find(series_name).title
      end
    end

    Rubicure::Movie.uniq_names.each do |movie_name|
      it "for movie #{movie_name}" do
        res = execute(%({ movie(movieName: "#{movie_name}") { #{selection(Types::MovieType)} } }))
        expect(res["errors"]).to be_nil
        expect(res["data"]["movie"]["title"]).to eq Rubicure::Movie.find(movie_name).title
      end
    end

    Rubicure::Girl.colors.each do |color|
      it "for color #{color}" do
        res = execute(%({ color(color: "#{color}") { #{selection(Types::ColorType)} } }))
        expect(res["errors"]).to be_nil
        expect(res["data"]["color"]["color"]).to eq color.to_s
      end
    end

    it "for allSeries, allMovies, colors and precureAll" do
      res = execute(<<QUERYSTRING)
{
  allSeries { #{selection(Types::SeriesType)} }
  allMovies { #{selection(Types::MovieType)} }
  colors { #{selection(Types::ColorType)} }
  precureAll { #{selection(Types::MemberType)} }
}
QUERYSTRING
      expect(res["errors"]).to be_nil
      expect(res["data"]["allSeries"].map { |e| e["seriesName"] }).to eq Precure.map(&:series_name)
      expect(res["data"]["allMovies"].map { |e| e["name"] }).to eq Rubicure::Movie.uniq_names.map(&:to_s)
      expect(res["data"]["colors"].map { |e| e["color"] }).to eq Rubicure::Girl.colors.map(&:to_s)
      expect(res["data"]["precureAll"].map { |e| e["memberName"] }).to eq Precure.all.map(&:girl_name)
    end
  end

  describe "heisei of a series that is still on air" do
    let(:on_air) { Precure.reject { |series| series.has_key?(:ended_date) } }

    it "is false instead of an error" do
      expect(on_air).not_to be_empty
      on_air.each do |series|
        res = execute(%({ series(seriesName: "#{series.series_name}") { heisei reiwa } }))
        expect(res).to eq({ "data" => { "series" => { "heisei" => "false", "reiwa" => "true" } } })
      end
    end
  end
end
