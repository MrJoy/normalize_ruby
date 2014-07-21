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
        head    = idx.first
        head    = @length + head if head < 0
        tail    = idx.last
        tail    = @length + tail if tail < 0
        return nil if head > @length

        divider = tail
        divider = @cutoff - 1 if divider >= @cutoff
        ll = (head <= divider) ? @l[head..divider] : []

        head    = (@cutoff < head) ? head - @cutoff : 0
        tail    = tail - @cutoff
        rr = (tail >= head) ? @r[head..tail] : nil

        result = ll
        result = rr ? result + rr : result
      end

      return result
    end

    def map(&block)
      return @l.map(&block) + @r.map(&block)
    end
  end
end
