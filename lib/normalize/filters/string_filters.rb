# TODO: Rule for "%q" DELIM ... DELIM => "%q(" ... ")" (also, %Q and any others
# TODO: that are relevant...)

# TODO: Rules for heredocs, and anything else that's relevant.
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
          Normalize::Token[{ kind: :on_tstring_beg, token: '"' }],
          Normalize::Token[{ kind: :on_tstring_end, token: '"' }],
        ].freeze

        SINGLE_QUOTED_STRING_LITERAL = [
          Normalize::Token[{ kind: :on_tstring_beg, token: "'" }],
          Normalize::Token[{ kind: :on_tstring_content }],
          Normalize::Token[{ kind: :on_tstring_end, token: "'" }],
        ].freeze

        DOUBLE_QUOTED_STRING_LITERAL = [
          Normalize::Token[{ kind: :on_tstring_beg, token: '"' }],
          Normalize::Token[{ kind: :on_tstring_content }],
          Normalize::Token[{ kind: :on_tstring_end, token: '"' }],
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

      # MATCH:        Empty double-quoted string.
      # REPLACEMENT:  Empty single-quoted string.
      ALWAYS_SINGLE_QUOTED_EMPTY = Filter.new(
        SimplePattern.new(Constants::DOUBLE_QUOTED_EMPTY_STRING_LITERAL),
        proc do |tokens|
          Constants::SINGLE_QUOTED_EMPTY_STRING_LITERAL
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

          tokens[0].token = '"'
          tokens[1].token = tokens[1].
            token.
            gsub(/\\\\/, '\\').
            split(/\n/, -1).
            map { |line| line.inspect.gsub(/(\A")|("\z)/, '') }.
            join("\n")
          tokens[2].token = '"'

          tokens
        end
      ).freeze

      # MATCH:        Non-empty double-quoted string, without single-quotes,
      #               escape sequences, or interpolation.
      # REPLACEMENT:  Equivalent single-quoted-string
      PREFER_SINGLE_QUOTED_NONEMPTY = Filter.new(
        ArbitraryPattern.new(lambda { |state, token|
          state ||= 0

          if Constants::DOUBLE_QUOTED_STRING_LITERAL[state] == token
            # We have a match!
            state += 1

            # Now, make sure the string is one we want to muck with!

            # Specifically, we don't want to have to escape:
            # * Single-quotes.
            # * Newlines.
            # * Various meta-characters.
            return [state, false] if token.kind == :on_tstring_content &&
                                     token.token =~ /'|\n|\\[^"#]/

            return [state, true]
          elsif state != 3
            # Got an unexpected token!
            return [state, false]
          end

          # No match.
          return [state, nil]
        }),
        proc do |tokens|
          tokens[0] = tokens[0].dup
          tokens[1] = tokens[1].dup
          tokens[2] = tokens[2].dup

          tokens[0].token = "'"
          tokens[1].token = tokens[1].
            token.
            gsub(/\\(["#\\])/, '\1').
            inspect.
            gsub(/\\\\/, '').
            gsub(/\\(["#\\])/, '\1').
            gsub(/(\A")|("\z)/, '')
          tokens[2].token = "'"

          tokens
        end
      ).freeze

    end
  end
end
