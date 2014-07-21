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

        DOUBLE_QUOTED_STRING_LITERAL = [
          Normalize::Token[{ kind: :on_tstring_beg, token: "\"" }],
          Normalize::Token[{ kind: :on_tstring_content }],
          Normalize::Token[{ kind: :on_tstring_end, token: "\"" }],
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

          tokens[0].token = "\""
          tokens[1].token = tokens[1].token.
            gsub(/\\'/, "'").
            gsub(/\\/, "\\"*3).
            gsub(/"/, '\"').
            gsub(/#\{/, "\\\#{")
          tokens[2].token = "\""

          tokens
        end
      ).freeze

      # MATCH:        Non-empty double-quoted string, without single-quotes,
      #               escape sequences, or interpolation.
      # REPLACEMENT:  Equivalent single-quoted-string
      PREFER_SINGLE_QUOTED_NONEMPTY = Filter.new(
        ArbitraryPattern.new(lambda { |token|
          unless token
            @state = 0
            return
          end

          if Constants::DOUBLE_QUOTED_STRING_LITERAL[@state] == token
            # We have a match!
            @state += 1

            if token.kind == :on_tstring_content
              # Now, make sure the string is one we want to muck with!

              return false if token.token =~ /'/ # We don't want to escape single-quotes.
              return false if token.token =~ /\n/ # We don't want to escape newlines.

              if token.token =~ /\\/
                # Uh-oh!  We have escaping.  Don't want to muck with this
                # string unless the ONLY form of escaping is `\"`!
                is_ok = true
                offset = 0
                while (offset = token.token.index('\\', offset + 1))# && offset < (token.token.length + 1)
                  escaped_char = token.token[offset + 1]
                  if escaped_char != '"'
                    is_ok = false
                    break
                  end
                end
                return is_ok
              end
            end

            return true
          elsif @state != 3
            # Got an unexpected token!
            return false
          end

          # No match.
          return nil
        }),
        proc do |tokens|
          tokens[0] = tokens[0].dup
          tokens[1] = tokens[1].dup
          tokens[2] = tokens[2].dup

          tokens[0].token = "'"
          tokens[1].token = tokens[1].
            token.
            inspect.
            gsub(/(\A")|("\z)/, '')
          tokens[2].token = "'"

          tokens
        end
      ).freeze

    end
  end
end
