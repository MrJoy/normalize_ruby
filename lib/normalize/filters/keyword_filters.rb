require_relative '../filters'

module Normalize
  module Filters
    module KeywordFilters
      module Constants
        SPACE                 = Normalize::Token[{ kind: :on_sp }]
        LPAREN                = Normalize::Token[{ kind: :on_lparen }]
        RPAREN                = Normalize::Token[{ kind: :on_rparen }]
        CONTROL_KEYWORDS      = [
          Normalize::Token[{ kind: :on_kw, token: 'if' }],
          Normalize::Token[{ kind: :on_kw, token: 'unless' }],
          Normalize::Token[{ kind: :on_kw, token: 'while' }],
        ]
        TERMINAL_NL           = Normalize::Token[{ kind: :on_nl }]
        TERMINAL_COMMENT      = Normalize::Token[{ kind: :on_comment}]
        STATEMENT_TERMINATORS = [
          TERMINAL_NL,
          TERMINAL_COMMENT,
        ]
      end

      # MATCH:        Control keywords with parens wrapping the control
      #               expression.
      # REPLACEMENT:  Equivalent statement without parens.
      PREFER_NO_PARENS_ON_CONTROL_KEYWORDS = Filter.new(
        ArbitraryPattern.new(lambda { |state, token|
          state ||= 0

          # CONTROL_KW = 'if' | 'unless' | 'while'

          # CONTROL_KW \s* '(' \s* (.*?) \s* ')' \s* (a:\n | b:COMMENT)
          #   =>
          # \1 ' ' \2 (a:\n | b: ' ' \3)

          # TODO: Rewrite these fucking state machines as generators. >.<
          case state
          when 0
            return [state + 1, true] if Constants::CONTROL_KEYWORDS.include?(token)

            return [state, false]
          when 1
            return [state,     true] if Constants::SPACE == token
            return [state + 1, true] if Constants::LPAREN == token

            return [state, false]
          when 2
            return [state, true] if Constants::SPACE == token ||
                                    Constants::RPAREN != token

            return [state + 1, true]
          when 3
            return [state, true] if Constants::SPACE == token

            # Done!
            return [state, nil] if Constants::STATEMENT_TERMINATORS.include?(token)

            return [state, false]
          end

          # No match.
          raise "This shouldn't have been possible! state == #{state}"
        }),
        proc do |tokens|
          output = [tokens.shift.dup]
          state = 0
          while tokens.length > 0
            token = tokens.shift
            case state
            when 0
              next if token == Constants::SPACE

              if token == Constants::LPAREN
                # TODO: Hoist this into a constant or some such...
                output << Normalize::Token[{ kind: :on_sp, token: ' ' }]
                # TODO: Track paren nesting and see if we need to do
                # TODO: anything...
                state += 1
                next
              end
            when 1
              next if token == Constants::SPACE
              tokens.unshift(token)
              state += 1
              next
            when 2
              if token == Constants::RPAREN
                state += 1
              elsif token == Constants::SPACE && tokens.length > 0 && tokens[0] == Constants::RPAREN
                # Drop it on the floor...
              else
                output << token.dup
              end

              next
            when 3
              next if token == Constants::SPACE

              if token == Constants::TERMINAL_COMMENT
                output << Normalize::Token[{ kind: :on_sp, token: ' ' }]
                output << token.dup
                break
              elsif token == Constants::TERMINAL_NL
                output << token.dup
                break
              end
            when 4
              raise "WAT: #{token.inspect}\n#{tokens.inspect}"
            end
          end

          output
        end
      ).freeze

    end
  end
end
