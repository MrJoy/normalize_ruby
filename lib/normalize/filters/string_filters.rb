# TODO: Rule for "%q" DELIM ... DELIM => "%q(" ... ")" (also, %Q and any others
# TODO: that are relevant...)

# TODO: Rules for heredocs, and anything else that's relevant.

# TODO: Parameterize this, or implement alternate behaviors, like
# TODO: prefer-single-quote.
require_relative '../filters'

module Normalize
  module Filters
    module StringFilters
      module Constants
        SINGLE_QUOTED_EMPTY_STRING_LITERAL = [
          Normalize::Token[{ kind: :on_tstring_beg, token: "'" }],
          Normalize::Token[{ kind: :on_tstring_end, token: "'" }],
        ].freeze

        DOUBLE_QUOTED_EMPTY_STRING_LITERAL = [
          Normalize::Token[{ kind: :on_tstring_beg, token: "\"" }],
          Normalize::Token[{ kind: :on_tstring_end, token: "\"" }],
        ].freeze

        SINGLE_QUOTED_STRING_LITERAL = [
          Normalize::Token[{ kind: :on_tstring_beg, token: "'" }],
          Normalize::Token[{ kind: :on_tstring_content }],
          Normalize::Token[{ kind: :on_tstring_end, token: "'" }],
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
          tokens[0] = tokens[0].dup
          tokens[1] = tokens[1].dup
          tokens[2] = tokens[2].dup

          tokens[0].token = "\""
          tokens[1].token = tokens[1].token.
            gsub(/\\'/, "'").
            gsub(/\\/, "\\"*3).
            gsub(/"/, '\"').
            gsub(/#\{/, "\\\#{")
          tokens[2].token = "\""

          tokens
        end
      )
    end
  end
end
