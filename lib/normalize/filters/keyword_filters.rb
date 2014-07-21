require_relative '../filters'

module Normalize
  module Filters
    module KeywordFilters
      module Constants
      end

      # MATCH:        Control keywords with parens wrapping the control expression.
      # REPLACEMENT:  Equivalent statement without parens.
      PREFER_NO_PARENS_ON_CONTROL_KEYWORDS = Filter.new(
        ArbitraryPattern.new(lambda { |token|
          unless token
            @state = 0
            return
          end

          # No match.
          return nil
        }),
        proc do |tokens|
          tokens
        end
      ).freeze

    end
  end
end
