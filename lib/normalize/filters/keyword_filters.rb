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
        ArbitraryPattern.new(lambda { |token|
          unless token
            @state = 0
            return
          end

          # CONTROL_KW = 'if' | 'unless' | 'while'

          # CONTROL_KW \s* '(' \s* (.*?) \s* ')' \s* \n
          #   =>
          # \1 ' ' \2 \n

          # CONTROL_KW \s* '(' \s* (.*?) \s* ')' \s* (COMMENT)
          #   =>
          # \1 ' ' \2 ' ' \3
          case @state
          when 0
            if Constants::CONTROL_KEYWORDS.include?(token)
              @state += 1
              return true
            end

            return false
          when 1
            return true if Constants::SPACE == token
            if Constants::LPAREN == token
              @state += 1
              return true
            end

            return false
          when 2
            return true if Constants::SPACE == token ||
                           Constants::RPAREN != token

            @state += 1
            return true
          when 3
            return true if Constants::SPACE == token

            # Done!
            return nil if Constants::STATEMENT_TERMINATORS.include?(token)

            return false
          end

          # No match.
          raise "This shouldn't have been possible! @state == #{@state}"

          # if Constants::DOUBLE_QUOTED_STRING_LITERAL[@state] == token
          #   # We have a match!
          #   @state += 1

          #   if token.kind == :on_tstring_content
          #     # Now, make sure the string is one we want to muck with!

          #     # Specifically, we don't want to have to escape...
          #     return false if token.token =~ /'/        # ...single-quotes.
          #     return false if token.token =~ /\n/       # ...newlines.
          #     return false if token.token =~ /\\[^"#]/  # ...various escapes.
          #   end

          #   return true
          # elsif @state != 3
          #   # Got an unexpected token!
          #   return false
          # end
        }),
        proc do |tokens|
          output = [tokens.shift.dup]
          state = 0
          while(tokens.length > 0)
            token = tokens.shift
            puts "#{state}: #{token.inspect}"
            case state
            when 0
              next if token == Constants::SPACE

              if token == Constants::LPAREN
                # TODO: Hoist this into a constant or some such...
                output << Normalize::Token[{ kind: :on_sp, token: ' ' }]
                # TODO: Track paren nesting and see if we need to do
                # TODO: anything...
                state += 1
              else
                raise "WAT: #{token.inspect}\n#{tokens.inspect}"
              end
            when 1
              next if token == Constants::SPACE

              if token == Constants::RPAREN
                state += 1
              else
                output << token.dup
              end
            when 2
              next if token == Constants::SPACE

              if token == Constants::TERMINAL_COMMENT
                output << Normalize::Token[{ kind: :on_sp, token: ' ' }]
                output << token.dup
                break
              elsif token == Constants::TERMINAL_NL
                output << token.dup
                break
              end
            when 3
              raise "WAT: #{token.inspect}\n#{tokens.inspect}"
            end
          end

          output
        end
      ).freeze

    end
  end
end
