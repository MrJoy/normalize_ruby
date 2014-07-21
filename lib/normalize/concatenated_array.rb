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
        result = Array.new(idx.max - idx.min)
        idx.each do |i|
          result[i - idx.min] = self[i]
        end
      end

      return result
    end
  end
end
