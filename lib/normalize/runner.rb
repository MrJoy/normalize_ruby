require 'parser/runner/ruby_rewrite'
require_relative 'filters/bare_control_statements'

module Normalize
  class Runner < ::Parser::Runner::RubyRewrite
    private

    # Temporarily overriding process until we can get a patch accepted upstream
    # to deal with the buffer-name-being-overwritten issue.
    def process(initial_buffer)
      buffer = initial_buffer
      original_name = buffer.name

      @rewriters.each do |rewriter_class|
        @parser.reset
        ast = @parser.parse(buffer)

        rewriter = rewriter_class.new
        new_source = rewriter.rewrite(buffer, ast)

        new_buffer = Parser::Source::Buffer.new(initial_buffer.name +
                                                '|after ' + rewriter_class.name)
        new_buffer.source = new_source

        @parser.reset
        new_ast = @parser.parse(new_buffer)

        # if !@modify && ast != new_ast
        #   $stderr.puts 'ASTs do not match:'

        #   old = Tempfile.new('old')
        #   old.write ast.inspect + "\n"; old.flush

        #   new = Tempfile.new('new')
        #   new.write new_ast.inspect + "\n"; new.flush

        #   IO.popen("diff -u #{old.path} #{new.path}") do |io|
        #     diff = io.read.
        #       sub(/^---.*/,    "--- #{buffer.name}").
        #       sub(/^\+\+\+.*/, "+++ #{new_buffer.name}")

        #     $stderr.write diff
        #   end

        #   exit 1
        # end

        buffer = new_buffer
      end

      if File.exist?(original_name)
        if initial_buffer.source != buffer.source
          File.open(original_name, 'w') do |file|
            file.write buffer.source
          end
        end
      else
        if input_size > 1
          puts "Rewritten content of #{buffer.name}:"
        end

        puts buffer.source
      end
    end

    def initialize
      super
      # Order-of-operations issue in parser.  Not sure how it works there, but
      # the code clearly seems to call `setup_option_parsing` *before* the
      # relevant constructor code runs, which in our case is wiping
      # `@rewriters`.  So, we just call it *again*.  Ugly, but it works.
      setup_option_parsing
    end

    def runner_name
      'normalize_ruby'
    end

    def setup_option_parsing
      # Don't try to set things up before constructor has done its thing.
      return unless(@rewriters)
      super

      # Remove options that aren't relevant anymore so CLI isn't confusing...
      @slop.options.reject! { |opt| ["modify", "version"].include?(opt.long) }

      # WARNING: We assume the AST can be modified by the filters -- which
      # WARNING: sounds obvious, but I've seen wackiness ensue that was caught
      # WARNING: by switching it off in some cases (IIRC, when playing with
      # WARNING: whitespace filtering or quote-symbol rewriting, or some such)
      # WARNING: and so we should consider re-enabling this stuff during
      # WARNING: testing to find possible corner-cases where a filter does
      # WARNING: incorrect things.
      @modify = true
      @rewriters << Normalize::Filters::BareControlStatements
    end
  end
end
