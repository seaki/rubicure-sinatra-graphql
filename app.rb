require 'sinatra'
require 'sinatra/json'
require 'rack/contrib'
require_relative 'graphql/schema'

use Rack::PostBodyContentTypeParser

post '/graphql' do
  result = Schema.execute(
    params[:query],
    variables: params[:variables],
    context: { current_user: nil },
  )
  json result
end
