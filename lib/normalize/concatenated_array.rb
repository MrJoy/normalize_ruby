module Normalize
  class ConcatenatedArray
    attr_reader :length

    def initialize(l, r)
      @l = l
      @r = r

      @length = @l.length + @r.length
      @cutoff = @l.length
    end

    def [](idx)
      result = nil
      if idx.kind_of?(Fixnum)
        idx = @length + idx if idx < 0
        if idx < @cutoff
          result = @l[idx]
        else
          result = @r[idx - @cutoff]
        end
      elsif idx.kind_of?(Range)
        # TODO: Replace this with a slicing array proxy...
        head = idx.first
        tail = idx.last
        tail = @length + tail if tail < 0
        result = Array.new(tail - head)
        (head..tail).each do |i|
          result[i - head] = self[i]
        end
      end

      return result
    end
  end
end
