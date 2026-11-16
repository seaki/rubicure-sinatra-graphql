require 'graphql'
require 'rubicure'
require_relative 'types/base_argument'
require_relative 'types/base_field'
require_relative 'types/base_object'
require_relative 'types/attack_message_type'
require_relative 'types/transform_message_type'
require_relative 'types/member_type'
require_relative 'types/color_type'
require_relative 'types/movie_type'
require_relative 'types/series_type'
require_relative 'types/query_type'

class Schema < GraphQL::Schema
  query Types::QueryType
end
