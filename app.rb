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

helpers do
  # A JSON body carries variables as an object; a form-encoded request usually carries them as a JSON string.
  def graphql_variables
    variables = params[:variables]
    variables = JSON.parse(variables) if variables.is_a?(String) && !variables.empty?
    return nil if variables.nil? || variables == ''
    raise TypeError, 'variables must be an object' unless variables.is_a?(Hash)
    variables
  rescue JSON::ParserError, TypeError
    halt 400, json(error: 'Failed to parse variables as a JSON object')
  end
end

get '/' do
  slim :index
end

post '/graphql' do
  result = Schema.execute(
    params[:query],
    variables: graphql_variables,
    operation_name: params[:operationName],
    context: { current_user: nil },
  )
  json result
end
