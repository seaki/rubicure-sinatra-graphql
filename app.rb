require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'rack/contrib'
require 'json'
require_relative 'graphql/schema'

# Rack::JSONBodyParser's default parser calls JSON.parse with `create_additions:`,
# which json 3 rejects, so every JSON request ended in 400. Parse the body ourselves.
use Rack::JSONBodyParser do |body|
  parsed = JSON.parse(body)
  raise TypeError, 'JSON body must be an object' unless parsed.is_a?(Hash)
  parsed
end

get '/' do
  slim :index
end

post '/graphql' do
  result = Schema.execute(
    params[:query],
    variables: params[:variables],
    operation_name: params[:operationName],
    context: { current_user: nil },
  )
  json result
end
