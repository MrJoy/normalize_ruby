require 'parser/runner'
require 'tempfile'
require_relative 'filters/bare_control_statements'

module Normalize
  class Runner < ::Parser::Runner
    private

    def runner_name
      'normalize_ruby'
    end

    def setup_option_parsing
      super

      # WARNING: We assume the AST can be modified by the filters -- which
      # WARNING: sounds obvious, but I've seen wackiness ensue that was caught
      # WARNING: by switching it off in some cases (IIRC, when playing with
      # WARNING: whitespace filtering or quote-symbol rewriting, or some such)
      # WARNING: and so we should consider re-enabling this stuff during
      # WARNING: testing to find possible corner-cases where a filter does
      # WARNING: incorrect things.
      # @modify = true
      @rewriters = []
      @rewriters << Object.const_get('Normalize::Filters::BareControlStatements')

      # @slop.on 'l=', 'load=', 'Load a rewriter' do |file|
      #   load_and_discover(file)
      # end
    end

    # def load_and_discover(file)
    #   load file

    #   const_name = file.
    #     sub(/\.rb$/, '').
    #     gsub(/(^|_)([a-z])/) do |m|
    #       "#{$2.upcase}"
    #     end

    #   @rewriters << Object.const_get(const_name)
    # end

    def process(initial_buffer)
      buffer = initial_buffer

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

      if File.exist?(buffer.name)
        File.open(buffer.name, 'w') do |file|
          file.write buffer.source
        end
      else
        if input_size > 1
          puts "Rewritten content of #{buffer.name}:"
        end

        puts buffer.source
      end
    end
  end

end
