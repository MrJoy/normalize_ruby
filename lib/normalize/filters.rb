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
        if expectation.kind_of?(Array)
          is_match = false unless expectation.include?(tokens[index + offset])
        else
          is_match = false unless expectation == tokens[index + offset]
        end

        break unless is_match
      end

      return is_match ? expectations.length : -1
    end
  end

  class ArbitraryPattern < Pattern
    attr_reader :rule

    def initialize(rule)
      @rule = rule
    end

    def match?(tokens, index)
      is_match = false
      offset   = 0
      state    = nil
      while !offset.nil?
        (state, token_matches) = rule.call(state, tokens[index + offset])
        if token_matches
          # Looks like we have a match in progress...
          is_match = true
        elsif token_matches.nil?
          # Done processing rules.  Yay!
          break
        elsif !token_matches
          # Mismatch on pattern!
          is_match = false
          break
        end
        offset += 1
      end

      return is_match ? (offset+1) : -1
    end
  end

  class Filter
    def initialize(pat, act)
      @pattern = pat
      @action  = act
    end

    def apply(tokens, index = 0)
      match_length = @pattern.match?(tokens, index)
      return [false, tokens] if match_length == -1

      last_index  = (match_length + index) - 1
      replacement = @action.call(tokens[index..last_index])
      result      = (replacement != tokens[index..last_index])
      tokens[index..last_index] = replacement if result

      return [result, tokens]
    end
  end
end
