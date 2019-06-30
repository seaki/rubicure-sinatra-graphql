require 'graphql'
require 'rubicure'

class QueryType < GraphQL::Schema::Object
  description "The query root of this schema"

  field :helloworld, String, null: false do
    description 'Hello, world!'
  end

  def helloworld
    'Hello, world!'
  end

  field :version, String, null: false, description: "Version number of this API"
  def version
    "0.0.0"
  end

end
