require_relative '../filters'

module Normalize
  module Filters
    module WhitespaceFilters
      module Constants
        SPACE                 = Normalize::Token[{ kind: :on_sp }]
        TERMINAL_NL           = Normalize::Token[{ kind: :on_nl }]
        IGNORED_NL            = Normalize::Token[{ kind: :on_ignored_nl }]
        COMMENT               = Normalize::Token[{ kind: :on_comment}]
      end

      # TODO: Test against other quote types, heredocs, etc.

      # MATCH:        Trailing whitespace not appearing as part of a string
      #               constant or part of a comment.
      # REPLACEMENT:  Nada.
      STRIP_TRAILING_WHITESPACE_FROM_STATEMENTS = Filter.new(
        SimplePattern.new([
          Constants::SPACE,
          [
            Constants::TERMINAL_NL,
            Constants::IGNORED_NL,
          ],
        ]),
        proc do |tokens|
          tokens.shift
          tokens
        end
      ).freeze

      # MATCH:        Trailing whitespace after comments.
      # REPLACEMENT:  Nada.
      STRIP_TRAILING_WHITESPACE_FROM_COMMENTS = Filter.new(
        SimplePattern.new([
          Constants::COMMENT,
        ]),
        proc do |tokens|
          output = [tokens.shift.dup]
          term = output[0].token.match(/(\r?\n)\z/)[1]
          output[0].token = output[0].token.rstrip + term
          output
        end
      ).freeze
    end
  end
end
