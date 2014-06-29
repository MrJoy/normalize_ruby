# TODO: Rule for "%q" DELIM ... DELIM => "%q(" ... ")"
module Normalize
  module Filters
    module StringFilters
      module Constants
        SINGLE_QUOTED_EMPTY_STRING_LITERAL = [
          { kind: :on_tstring_beg, token: "'" }.freeze,
          { kind: :on_tstring_end, token: "'" }.freeze,
        ].freeze

        DOUBLE_QUOTED_EMPTY_STRING_LITERAL = [
          { kind: :on_tstring_beg, token: "\"" }.freeze,
          { kind: :on_tstring_end, token: "\"" }.freeze,
        ].freeze

        SINGLE_QUOTED_STRING_LITERAL = [
          { kind: :on_tstring_beg, token: "'" }.freeze,
          { kind: :on_tstring_content }.freeze,
          { kind: :on_tstring_end, token: "'" }.freeze,
        ].freeze
      end

      # MATCH:        Empty single-quoted string.
      # REPLACEMENT:  Empty double-quoted string.
      ALWAYS_DOUBLE_QUOTED_EMPTY = Filter.new(
        SimplePattern.new(Constants::SINGLE_QUOTED_EMPTY_STRING_LITERAL),
        proc do |tokens|
          Constants::DOUBLE_QUOTED_EMPTY_STRING_LITERAL
        end
      ).freeze

      # MATCH:        Non-empty single-quoted string.
      # REPLACEMENT:  Non-empty double-quoted string.
      ALWAYS_DOUBLE_QUOTED_NONEMPTY = Filter.new(
        SimplePattern.new(Constants::SINGLE_QUOTED_STRING_LITERAL),
        proc do |tokens|
          tokens[0][:token] = "\""
          tokens[1][:token] = tokens[1][:token].
            gsub(/\\'/, "'").
            gsub(/\\/, "\\"*3).
            gsub(/"/, '\"').
            gsub(/#\{/, "\\\#{")
          tokens[-1][:token] = "\""

          tokens
        end
      )
    end
  end
end
