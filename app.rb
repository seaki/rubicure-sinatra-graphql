require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'rack/contrib'
require_relative 'graphql/schema'

use Rack::PostBodyContentTypeParser

get '/' do
  slim :index
end

post '/graphql' do
  result = Schema.execute(
    params[:query],
    variables: params[:variables],
    context: { current_user: nil },
  )
  json result
end
