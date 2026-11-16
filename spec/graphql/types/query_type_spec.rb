require File.expand_path '../../../spec_helper.rb', __FILE__

RSpec.describe Types::QueryType do
  let(:headers) do
    { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  let(:query) do
    { "query" => query_string }
  end

  # Call `result` to execute the query
  let(:result) do
    post '/graphql', query, headers
    res = JSON.parse(last_response.body)
    # Print any errors
    if res["errors"]
      pp res
    end
    res
  end

  describe "query" do
    let(:query_string) do
      <<QUERYSTRING
{
  allMovies
  {
    name
  }
  allSeries
  {
    seriesName
  }
  colors
  {
    color
  }
  precureAllStars(series: "ns3")
  {
    girlName
  }
  precureDreamStars
  {
    girlName
  }
  precureSuperStars
  {
    girlName
  }
  precureMiracleLeap
  {
    girlName
  }
  precureAllGirls
  {
    girlName
  }
  precureAll
  {
    girlName
  }
}
QUERYSTRING
    end

    context "allMovies" do
      it { expect(result["data"]["allMovies"].count).to eq Rubicure::Movie.uniq_names.count }
    end

    context "allSeries" do
      it { expect(result["data"]["allSeries"].count).to eq Precure.count }
    end

    context "colors" do
      it { expect(result["data"]["colors"].count).to eq Rubicure::Girl.colors.count }
    end

    context "precureAllStars(series: \"ns3\")" do
      it { expect(result["data"]["precureAllStars"].count).to eq Precure.all_stars(:ns3).count }
    end

    context "precureDreamStars" do
      it { expect(result["data"]["precureDreamStars"].count).to eq Precure.dream_stars.count }
    end

    context "precureSuperStars" do
      it { expect(result["data"]["precureSuperStars"].count).to eq Precure.super_stars.count }
    end

    context "precureMiracleLeap" do
      it { expect(result["data"]["precureMiracleLeap"].count).to eq Precure.miracle_leap.count }
    end

    context "precureAllGirls" do
      it { expect(result["data"]["precureAllGirls"].count).to eq Precure.all_girls.count }
    end

    context "precureAll" do
      it { expect(result["data"]["precureAll"]).to eq result["data"]["precureAllGirls"] }
    end
  end

  describe "precureAllStars without argument" do
    let(:query_string) do
      <<QUERYSTRING
{
  precureAllStars
  {
    girlName
  }
}
QUERYSTRING
    end

    context "precureAllStars" do
      it { expect(result["data"]["precureAllStars"].count).to eq Precure.all_stars.count }
    end
  end

  describe "current series" do
    let(:query_string) do
      <<QUERYSTRING
{
  now
  {
    seriesName
  }
  current
  {
    seriesName
  }
}
QUERYSTRING
    end

    context "now at 2020-01-26" do
      around do |e|
        Timecop.freeze('2020-01-26') { e.run }
      end
      it "returns current series" do
        expect(result["data"]["now"]["seriesName"]).to eq Precure.now.series_name
      end
    end

    context "current at 2020-01-26" do
      around do |e|
        Timecop.freeze('2020-01-26') { e.run }
      end
      it "returns current series" do
        expect(result["data"]["current"]["seriesName"]).to eq Precure.now.series_name
      end
    end

    context "at 2020-02-01" do
      around do |e|
        Timecop.freeze('2020-02-01') { e.run }
      end
      it "returns error" do
        post '/graphql', query
        res = JSON.parse(last_response.body)
        expect(res["data"]).to be_nil
        expect(res["errors"].map { |e| e["message"] }).to eq ["Not on air precure!", "Not on air precure!"]
      end
    end
  end

  describe "series(seriesName: now)" do
    let(:query_string) do
      <<QUERYSTRING
{
  series(seriesName: "now")
  {
    seriesName
  }
}
QUERYSTRING
    end

    around do |e|
      Timecop.freeze('2020-01-26') { e.run }
    end
    it "returns current series" do
      expect(result["data"]["series"]["seriesName"]).to eq Precure.now.series_name
    end
  end

  describe "series(seriesName: current)" do
    let(:query_string) do
      <<QUERYSTRING
{
  series(seriesName: "current")
  {
    seriesName
  }
}
QUERYSTRING
    end

    around do |e|
      Timecop.freeze('2020-01-26') { e.run }
    end
    it "returns current series" do
      expect(result["data"]["series"]["seriesName"]).to eq Precure.now.series_name
    end
  end

  describe "series(seriesName:)" do
    # Unlike `result`, a query that makes the server call Kernel#exit fails the example instead of ending the run.
    def execute(query_string)
      post '/graphql', { "query" => query_string }
      JSON.parse(last_response.body)
    rescue SystemExit
      raise "the query terminated the process"
    end

    it "finds every series by its name, including aliases" do
      Rubicure::Series.names.each do |name|
        res = execute(%({ series(seriesName: "#{name}") { title } }))
        expect(res).to eq({ "data" => { "series" => { "title" => Rubicure::Series.find(name).title } } })
      end
    end

    # The argument must not reach Precure.send: these are methods of Precure, not series.
    ["unknown", "all_stars", "class", "object_id", "send", "exit", ""].each do |name|
      it "returns an error for #{name.inspect}" do
        res = execute(%({ series(seriesName: "#{name}") { title } }))
        expect(res).to match(
          "data" => nil,
          "errors" => [a_hash_including("message" => "unknown series: #{name}", "path" => ["series"])]
        )
      end
    end

    it "does not call a method of Precure with the name" do
      expect(Rubicure::Core.instance).not_to receive(:all_stars)
      execute(%({ series(seriesName: "all_stars") { title } }))
    end
  end

  describe "version" do
    let(:query_string) do
      <<QUERYSTRING
{
  version
}
QUERYSTRING
    end

    context "version" do
      it { expect(result["data"]["version"]).not_to be_nil }
      it { expect(result["data"]["version"]).to match(/\A\d+(\.\d+){3}\z/) }
    end
  end

  describe "a query that cannot be answered" do
    # `result` prints the errors it receives; these examples expect them.
    def execute(query_string)
      post '/graphql', { "query" => query_string }
      JSON.parse(last_response.body)
    end

    shared_examples "a GraphQL error" do |message|
      it "returns errors and no data" do
        res = execute(query_string)
        expect(last_response).to be_ok
        expect(res["data"]).to be_nil
        expect(res["errors"]).not_to be_empty
        expect(res["errors"].map { |e| e["message"] }).to eq [message] if message
      end
    end

    context "with a syntax error" do
      let(:query_string) { "{ version " }
      it_behaves_like "a GraphQL error"
    end

    context "with a field that does not exist" do
      let(:query_string) { "{ nope }" }
      it_behaves_like "a GraphQL error"
    end

    context "with a required argument left out" do
      let(:query_string) { "{ member { memberName } }" }
      it_behaves_like "a GraphQL error"
    end

    # A name rubicure does not know, or asking for the series on air while none is,
    # is answered with a GraphQL error rather than with rubicure's exception.
    {
      '{ member(memberName: "unknown") { memberName } }' => ["member", "unknown member: unknown"],
      '{ member(memberName: "") { memberName } }' => ["member", "unknown member: "],
      '{ member(memberName: "class") { memberName } }' => ["member", "unknown member: class"],
      '{ girl(girlName: "unknown") { girlName } }' => ["girl", "unknown girl: unknown"],
      '{ movie(movieName: "unknown") { name } }' => ["movie", "unknown movie: unknown"],
      '{ movie(movieName: "") { name } }' => ["movie", "unknown movie: "],
      '{ precureAllStars(series: "unknown") { memberName } }' => ["precureAllStars", "unknown movie: unknown"],
      '{ color(color: "unknown") { color } }' => ["color", "unknown color: unknown"],
      '{ color(color: "") { color } }' => ["color", "unknown color: "],
    }.each do |query, (field, message)|
      context "with #{query}" do
        it "returns an error" do
          expect(execute(query)).to match(
            "data" => nil,
            "errors" => [a_hash_including("message" => message, "path" => [field])]
          )
        end
      end
    end

    context "with precureAllStars of an empty series" do
      it "is the same as without the argument" do
        res = execute('{ a: precureAllStars(series: "") { memberName } b: precureAllStars { memberName } }')
        expect(res["errors"]).to be_nil
        expect(res["data"]["a"]).to eq res["data"]["b"]
      end
    end

    context "with series(seriesName: \"now\") while no series is on air" do
      around do |e|
        Timecop.freeze('2020-02-01') { e.run }
      end
      let(:query_string) { %({ series(seriesName: "now") { seriesName } }) }
      it_behaves_like "a GraphQL error", "Not on air precure!"
    end
  end
end
