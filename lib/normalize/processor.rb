require 'ripper'
require_relative './token'

module Normalize
  class Processor
    attr_reader :filters

    def initialize(*args)
      @filters = Array(args)
    end

    def parse(src, fname)
      return Ripper.
        lex(src, fname).
        map do |((line_no, col_no), kind, token)|
          Token.new(line_no, col_no, kind, token)
        end
    end

    def process(tokens)
      filter_list = filters.to_a
      raise "Must specify at least one filter!" if(filter_list.length == 0)
      is_match = true
      while(is_match)
        idx = 0
        is_match = true
        while(idx < tokens.length)
          filters.each do |filter|
            (is_match, tokens) = filter.apply(tokens, idx)
          end
          idx += 1
        end
      end

      return tokens
    end
  end
end
