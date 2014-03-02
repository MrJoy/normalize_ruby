require 'forwardable'

require 'rope/node'

module Rope
  # Specifies a leaf node that contains a basic string
  class ArrayNode < Node
    extend Forwardable

    def_delegators :@data, :slice
    def_delegator :@data, :slice, :'[]'

    # Initializes a node that contains a basic string
    def initialize(arr)
      @data = arr
      @length = arr.length
      @depth = 0
    end

    def subtree(from, length)
      if length == @data.length
        self
      else
        ArrayNode.new(@data.slice(from, length))
      end
    end
  end
end
