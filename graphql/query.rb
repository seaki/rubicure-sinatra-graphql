require 'graphql'

class QueryType < GraphQL::Schema::Object
  description "The query root of this schema"

  field :helloworld, String, null: false do
    description 'Hello, world!'
  end

  def helloworld
    'Hello, world!'
  end
end
