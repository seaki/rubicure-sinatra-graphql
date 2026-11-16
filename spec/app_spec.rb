require 'spec_helper'

describe "rubicure-sinatra-graphql Application" do
  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end

  it "should allow accessing the /graphql endpoint" do
    post '/graphql'
    expect(last_response).to be_ok
  end

  it "should show the home page with a link to the endpoint" do
    get '/'
    expect(last_response.content_type).to start_with "text/html"
    expect(last_response.body).to include("<h1>rubicure-sinatra-graphql</h1>", 'href="./graphql"')
  end

  it "should answer in JSON with an error when no query is given" do
    post '/graphql'
    expect(last_response.content_type).to eq "application/json"
    res = JSON.parse(last_response.body)
    expect(res["data"]).to be_nil
    expect(res["errors"]).not_to be_empty
  end

  it "should answer 404 for an unknown path" do
    get '/nothing'
    expect(last_response.status).to eq 404
  end

  describe "POST /graphql with a JSON body" do
    # The content type has to be given as CONTENT_TYPE: rack-test ignores a 'Content-Type' env key
    # and would send the request form-encoded.
    def post_json(body)
      post '/graphql', body, 'CONTENT_TYPE' => 'application/json'
    end

    it "executes the query" do
      post_json({ "query" => "{ version }" }.to_json)
      expect(last_request.media_type).to eq "application/json"
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)["data"]["version"]).not_to be_nil
    end

    it "passes variables to the query" do
      post_json({
        "query" => "query($name: String!) { member(memberName: $name) { memberName } }",
        "variables" => { "name" => "miracle" },
      }.to_json)
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)).to eq({ "data" => { "member" => { "memberName" => "cure_miracle" } } })
    end

    it "returns 400 when the body is not valid JSON" do
      post_json('{ "query": ')
      expect(last_response.status).to eq 400
    end

    it "returns 400 when the body is not a JSON object" do
      post_json('["{ version }"]')
      expect(last_response.status).to eq 400
    end
  end

  describe "POST /graphql with several operations in one document" do
    let(:document) { "query Version { version } query Colors { colors { color } }" }

    it "executes the operation named by operationName in a JSON body" do
      post '/graphql', { "query" => document, "operationName" => "Colors" }.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(JSON.parse(last_response.body)).to eq({ "data" => { "colors" => Rubicure::Girl.colors.map { |color| { "color" => color.to_s } } } })
    end

    it "executes the operation named by operationName in a form-encoded request" do
      post '/graphql', { "query" => document, "operationName" => "Version" }
      expect(JSON.parse(last_response.body)["data"].keys).to eq ["version"]
    end

    it "returns an error when operationName is missing" do
      post '/graphql', { "query" => document }
      res = JSON.parse(last_response.body)
      expect(res["data"]).to be_nil
      expect(res["errors"]).not_to be_empty
    end
  end

  describe "POST /graphql with variables in a form-encoded request" do
    let(:query_string) { "query($name: String!) { member(memberName: $name) { memberName } }" }
    let(:expected) { { "data" => { "member" => { "memberName" => "cure_miracle" } } } }

    it "accepts variables as a JSON string" do
      post '/graphql', { "query" => query_string, "variables" => '{"name":"miracle"}' }
      expect(JSON.parse(last_response.body)).to eq expected
    end

    it "accepts variables as nested parameters" do
      post '/graphql', { "query" => query_string, "variables" => { "name" => "miracle" } }
      expect(JSON.parse(last_response.body)).to eq expected
    end

    it "ignores empty variables" do
      post '/graphql', { "query" => "{ version }", "variables" => "" }
      expect(JSON.parse(last_response.body)["data"]["version"]).not_to be_nil
    end

    it "ignores the string null as variables" do
      post '/graphql', { "query" => "{ version }", "variables" => "null" }
      expect(JSON.parse(last_response.body)["data"]["version"]).not_to be_nil
    end
  end

  # The same answers as rubicure-graphql gives.
  describe "POST /graphql with variables that are not an object" do
    def post_json(variables)
      post '/graphql', { "query" => "{ version }", "variables" => variables }.to_json, 'CONTENT_TYPE' => 'application/json'
    end

    def rejected_with(message)
      expect(last_response.status).to eq 400
      expect(last_response.content_type).to eq "application/json"
      expect(JSON.parse(last_response.body)).to eq({ "errors" => [{ "message" => message }] })
    end

    it "rejects a string that is not JSON" do
      post_json("{")
      rejected_with "variables is not valid JSON"
    end

    it "rejects a JSON string that is not an object" do
      post_json("[1]")
      rejected_with "variables must be an object"
    end

    it "rejects a number" do
      post_json(1)
      rejected_with "variables must be an object"
    end

    it "rejects an array" do
      post_json([1])
      rejected_with "variables must be an object"
    end

    it "rejects a form-encoded string that is not JSON" do
      post '/graphql', { "query" => "{ version }", "variables" => "{" }
      rejected_with "variables is not valid JSON"
    end

    it "accepts null" do
      post_json(nil)
      expect(JSON.parse(last_response.body)["data"]["version"]).not_to be_nil
    end
  end
end
