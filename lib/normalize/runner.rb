require 'parser/runner/ruby_rewrite'
require_relative 'filters/bare_control_statements'

module Normalize
  class Runner < ::Parser::Runner::RubyRewrite
    private

    # Overriding parent class here in order to handle syntax errors in the
    # resulting AST gracefully (I.E. set a non-zero exit code).
    def process_buffer(buffer)
      @parser.reset

      process(buffer)

      @source_count += 1
      @source_size  += buffer.source.size

    rescue Parser::SyntaxError => pse
      $stderr.puts("Failed due to syntax error: #{pse.message}")
      exit 1
      # skip

    rescue StandardError
      $stderr.puts("Failed on: #{buffer.name}")
      raise
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
