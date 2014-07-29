begin
  require 'parser/current'
rescue NotImplementedError
  warn 'Falling back to Ruby 2.1 parser.'
  require 'parser/ruby21'
  Parser::CurrentRuby = Parser::Ruby21 # rubocop:disable ConstantName
end
require 'astrolabe/node'
require 'unparser'
require_relative './token'

module Normalize
  module AST
    class Builder < Parser::Builders::Default
      def n(type, children, source_map)
        Node.new(type, children, location: source_map)
      end
    end

    class Node < Astrolabe::Node
      attr_reader :metadata

      def initialize(type, children = [], properties = {})
        @metadata = {}
        super
      end
    end
  end

  class Processor
    attr_reader :filters

    def initialize(*args)
      @filters = Array(args)
      @builder = AST::Builder.new
      @parser = Parser::CurrentRuby.new(@builder)
      @parser.diagnostics.consumer = lambda do |diag|
        puts "DEBUG: #{diag.render}"
      end
    end

    def parse(src, fname)
      @buffer = Parser::Source::Buffer.new(fname)
      @buffer.source = src

      @ast, comments = @parser.parse_with_comments(@buffer)
      @ast = Parser::Source::Comment.associate(@ast, comments)

      return self
    ensure
      @parser.reset
    end

    def process
      filter_list = filters.to_a
      return self if filter_list.length == 0

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

      return self
    end

    def to_s
      return @ast.source #Unparser.unparse(ast)
    end
  end
end
