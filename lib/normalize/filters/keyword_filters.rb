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
        STATEMENT_TERMINATORS = [
          Normalize::Token[{ kind: :on_nl }],
          Normalize::Token[{ kind: :on_comment}],
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
              puts "PING1! #{token.inspect}"
              @state += 1
              return true
            end

            return false
          when 1
            return true if Constants::SPACE == token
            if Constants::LPAREN == token
              puts "PING2! #{token.inspect}"
              @state += 1
              return true
            end

            return false
          when 2
            return true if Constants::SPACE == token ||
                           Constants::RPAREN != token

            puts "PING3! #{token.inspect}"
            @state += 1
            return true
          when 3
            return true if Constants::SPACE == token

            if Constants::STATEMENT_TERMINATORS.include?(token)
              return nil
            end

            return false
          end

          # No match.
          raise "This shouldn't have been possible! @state == #{@state}"
        }),
        proc do |tokens|
          tokens
        end
      ).freeze

    end
  end
end
