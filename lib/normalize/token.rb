module Normalize
  class Token
    attr_reader :line, :col, :kind, :token
    attr_reader :skip_line, :skip_col, :skip_kind, :skip_token

    def initialize(*args)
      if(args.length == 4)
        (@line, @col, @kind, @token) = *args
        @skip_line = @skip_col = @skip_kind = @skip_token = false
      elsif(args.length == 1 && args[0].is_a?(Hash))
        @line       = args[0][:line]
        @col        = args[0][:col]
        @kind       = args[0][:kind]
        @token      = args[0][:token]

        @skip_line  = !args[0].has_key?(:line)
        @skip_col   = !args[0].has_key?(:col)
        @skip_kind  = !args[0].has_key?(:kind)
        @skip_token = !args[0].has_key?(:token)
      else
        raise "Expected a Hash or Array[0..3], got: #{args.inspect}"
      end
    end

    def self.[](*args)
      return Token.new(*args)
    end

    def line=(val)
      @line       = val
      @skip_line  = false
    end

    def col=(val)
      @col        = val
      @skip_col   = false
    end

    def kind=(val)
      @kind       = val
      @skip_kind  = false
    end

    def token=(val)
      @token      = val
      @skip_token = false
    end

    def to_h
      result = {}
      result[:line]   = @line   unless(@skip_line)
      result[:col]    = @col    unless(@skip_col)
      result[:kind]   = @kind   unless(@skip_kind)
      result[:token]  = @token  unless(@skip_token)
      return result
    end

    def to_s
      return "Normalize::Token[#{to_h.inspect}]"
    end

    def dup
      return Token.new(to_h)
    end

    def ==(other)
      if(other.is_a?(Hash))
        other = Token[other]
      elsif(other.is_a?(Array))
        other = Token[*other]
      end

      raise "Can't compare Token to #{other.inspect}!" unless(other.is_a?(Token))

      line_matches  = @skip_line  || other.skip_line  || (@line   == other.line)
      col_matches   = @skip_col   || other.skip_col   || (@col    == other.col)
      kind_matches  = @skip_kind  || other.skip_kind  || (@kind   == other.kind)
      token_matches = @skip_token || other.skip_token || (@token  == other.token)

      return line_matches && col_matches && kind_matches && token_matches
    end
  end
end
