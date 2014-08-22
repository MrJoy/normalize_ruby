require 'parser/runner/ruby_rewrite'

module Normalize
  class TestRunner < ::Parser::Runner::RubyRewrite
    private

    def initialize(rewriters)
      require 'parser/current'
      @parser_class                            = Parser::CurrentRuby
      @rewriters                               = Array(rewriters)
      @parser                                  = @parser_class.new
      @parser.diagnostics.all_errors_are_fatal = true
      @parser.diagnostics.ignore_warnings      = true # TODO: Do we want this?

      @parser.diagnostics.consumer             = lambda do |diagnostic|
        STDERR.puts(diagnostic.render)
      end
    end

    # Temporarily overriding process until we can get a patch accepted upstream
    # to deal with the buffer-name-being-overwritten issue.
    def process(fragment)
      initial_name  = "(fragment)"
      buffer        = Source::Buffer.new(initial_name)
      buffer.source = fragment

      @rewriters.each do |rewriter_class|
        @parser.reset
        ast = @parser.parse(buffer)

        rewriter = rewriter_class.new
        new_source = rewriter.rewrite(buffer, ast)

        new_buffer = Parser::Source::Buffer.new(initial_name +
                                                '|after ' + rewriter_class.name)
        new_buffer.source = new_source

        buffer = new_buffer
      end

      return buffer.source
    end
  end
end
