require 'parser/runner/ruby_rewrite'
require_relative 'filters/bare_control_statements'

module Normalize
  class Runner < ::Parser::Runner::RubyRewrite
    private

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
      next unless(@rewriters)
      super

      # WARNING: We assume the AST can be modified by the filters -- which
      # WARNING: sounds obvious, but I've seen wackiness ensue that was caught
      # WARNING: by switching it off in some cases (IIRC, when playing with
      # WARNING: whitespace filtering or quote-symbol rewriting, or some such)
      # WARNING: and so we should consider re-enabling this stuff during
      # WARNING: testing to find possible corner-cases where a filter does
      # WARNING: incorrect things.
      @modify = true
      @rewriters << Object.const_get('Normalize::Filters::BareControlStatements')

      # @slop.on 'l=', 'load=', 'Load a rewriter' do |file|
      #   load_and_discover(file)
      # end
    end
  end
end
