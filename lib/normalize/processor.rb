require 'ripper'

module Normalize
  class Processor
    def parse(src, fname)
      return Ripper.
        lex(src, fname).
        map do |((line_no, col_no), kind, token)|
          { line: line_no, col: col_no, kind: kind, token: token }
        end
    end

    def process(tokens)
      is_match = true
      while(is_match)
        idx = 0
        is_match = true
        while(idx < tokens.length)
          RULES.select do |(pattern, action)|
            is_match = true
            last_idx = idx
            pattern.each_with_index do |expectation, offset|
              last_idx = idx + offset

              expectation.keys.each do |key|
                is_match = false unless(expectation[key] == tokens[idx + offset][key])
              end

              break unless(is_match)
            end

            if(is_match)
              prefix = (idx > 0) ? tokens[0..(idx-1)] : []
              suffix = (last_idx < tokens.length) ? tokens[(last_idx+1)..-1] : []
              replacement = action.call(tokens[idx..last_idx])

              tokens = prefix + replacement + suffix
              idx = prefix.length + replacement.length - 1
            end
          end
          idx += 1
        end
      end

      return tokens
    end
  end
end
