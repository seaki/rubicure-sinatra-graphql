require File.expand_path '../spec_helper.rb', __FILE__

RSpec.describe QueryType do
  let(:headers) do
    { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  context 'helloworld' do
    let(:query) do
      { "query" => "{ helloworld }" }
    end

    it 'returns valid response code' do
      post '/graphql', query, headers
      expect(last_response).to be_ok
    end

    it 'returns response body' do
      post '/graphql', query, headers
      expect(last_response.body).not_to be_nil
    end

    it 'returns valid response body' do
      post '/graphql', query, headers
      @json = JSON.parse(last_response.body)
      expect(@json['data']['helloworld']).to include("Hello, world!")
    end
  end

  context 'version' do
    let(:query) do
      { "query" => "{ version }" }
    end

    it 'returns valid version number' do
      post '/graphql', query, headers
      @json = JSON.parse(last_response.body)
      expect(@json['data']['version']).to include("0.0.0")
    end
  end
end
