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

# The request cannot be executed because "variables" is not a JSON object.
class InvalidVariablesError < StandardError; end

# prepare_variables and parse_variables follow GraphqlController of rubicure-graphql,
# so both apps accept and reject the same variables with the same messages.
helpers do
  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        parse_variables(variables_param)
      else
        {}
      end
    when Hash
      variables_param
    when nil
      {}
    else
      raise InvalidVariablesError, "variables must be an object"
    end
  end

  def parse_variables(json)
    variables = JSON.parse(json)
    return {} if variables.nil?
    raise InvalidVariablesError, "variables must be an object" unless variables.is_a?(Hash)

    variables
  rescue JSON::ParserError
    raise InvalidVariablesError, "variables is not valid JSON"
  end
end

get '/' do
  slim :index
end

post '/graphql' do
  begin
    variables = prepare_variables(params[:variables])
  rescue InvalidVariablesError => e
    halt 400, json(errors: [{ message: e.message }])
  end
  result = Schema.execute(
    params[:query],
    variables: variables,
    operation_name: params[:operationName],
    context: { current_user: nil },
  )
  json result
end
