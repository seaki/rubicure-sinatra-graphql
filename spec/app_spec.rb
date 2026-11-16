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
end
