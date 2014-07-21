#!/usr/bin/env ruby

require_relative '../lib/normalize'

fname = ARGV.shift
outname = ARGV.shift
raise 'Must specify filename!' unless(fname && fname != '' && fname != '-')
raise "No such file '#{fname}'!" unless(File.exist?(fname) || fname == '-')
outname = fname unless(outname && outname != '' && fname != '-')

processor = Normalize::Processor.new(
  Normalize::Filters::StringFilters::ALWAYS_SINGLE_QUOTED_EMPTY,
  Normalize::Filters::StringFilters::PREFER_SINGLE_QUOTED_NONEMPTY,
)

if(fname == '-')
  contents = STDIN.read
  effective_fname = '<stdin>'
else
  contents = File.read(fname)
  effective_fname = fname
end
tokens = processor.parse(contents, effective_fname)
tokens = processor.process(tokens)
result = tokens.map { |token| token.token }.join

if(fname == '-')
  puts result
else
  File.open(outname, 'w') do |fh|
    fh.write(result)
  end
end
