# TODO: Rule for "if" \s* "(" \s* (.+) \s* ")" => "if \1"
require_relative './token'

module Normalize
  class Pattern
    def match?(tokens, index)
      return -1
    end
  end

  class SimplePattern < Pattern
    attr_reader :expectations

    def initialize(token_list)
      @expectations = token_list
    end

    def match?(tokens, index)
      is_match = true
      expectations.each_with_index do |expectation, offset|
        is_match = false unless(expectation == tokens[index + offset])
        break unless(is_match)
      end

      return is_match ? expectations.length : -1
    end
  end

  class Filter
    def initialize(pat, act)
      @pattern = pat
      @action = act
    end

    def apply(tokens, index)
      match_length = @pattern.match?(tokens, index)
      return [false, tokens] if(match_length == -1)

      last_index = (match_length + index) - 1
      prefix = (index > 0) ? tokens[0..(index-1)] : []
      suffix = (last_index < tokens.length) ? tokens[(last_index+1)..-1] : []
      replacement = @action.call(tokens[index..last_index])

      return [true, prefix + replacement + suffix]
    end
  end
end
