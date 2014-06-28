# Based on: https://github.com/alindeman/rope
require 'forwardable'

require 'rope/concat_node'
require 'rope/array_node'

module Rope
  class Rope
    extend Forwardable

    def_delegators :@root, :to_a, :length, :rebalance!

    # Initializes a new rope
    def initialize(arg=nil)
      case arg
      when Node
        @root = arg
      when NilClass
        @root = ArrayNode.new([])
      when Array
        @root = ArrayNode.new(arg)
      else
        @root = ArrayNode.new([arg])
      end
    end

    # Concatenates this rope with another rope or string
    def +(other)
      Rope.new(concatenate(other))
    end

    # Tests whether this rope is equal to another rope
    def ==(other)
      to_a == other.to_a
    end

    # Creates a copy of this rope
    def dup
      Rope.new(root)
    end

    # Gets a slice of this rope
    def slice(*args)
      slice = root.slice(*args)

      case slice
      when Fixnum # slice(Fixnum) returns a plain Fixnum
        slice
      when Node, Array # create a new Rope with the returned tree as the root
        Rope.new(slice)
      else
        nil
      end
    end

    alias :[] :slice

  protected

    # Root node (could either be a ArrayNode or some child of LeafNode)
    attr_reader :root

  private
    # Generate a concatenation node to combine this rope and another rope
    # or string
    def concatenate(other)
      # TODO: Automatically balance the tree if needed
      case other
      when NilClass
        root
      when Rope
        ConcatenationNode.new(root, other.root)
      when Array
        ConcatenationNode.new(root, ArrayNode.new(other))
      else
        ConcatenationNode.new(root, ArrayNode.new([other]))
      end
    end
  end
end
