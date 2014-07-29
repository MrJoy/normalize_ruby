require 'parser'
require 'unparser'
require_relative './token'

module Normalize
  class Processor
    attr_reader :filters

    def initialize(*args)
      @filters = Array(args)
      @parser = Parser::CurrentRuby.new
      @parser.diagnostics.consumer = lambda do |diag|
        puts "DEBUG: #{diag.render}"
      end
    end

    def parse(src, fname)
      buffer = Parser::Source::Buffer.new(fname)
      buffer.source = src

      return @parser.parse(buffer)
    ensure
      @parser.reset
    end

    def process(ast)
      filter_list = filters.to_a
      return ast if filter_list.length == 0

      # is_match = true
      # while is_match
      #   idx = 0
      #   is_match = true
      #   while idx < tokens.length
      #     filters.each do |filter|
      #       (is_match, tokens) = filter.apply(tokens, idx)
      #     end
      #     idx += 1
      #   end
      # end

      return ast
    end

    def unparse(ast)
      return Unparser.unparse(ast)
    end
  end
end
