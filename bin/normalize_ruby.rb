#!/usr/bin/env ruby

require_relative '../lib/normalize'

fname = ARGV.shift
outname = ARGV.shift
raise "Must specify filename!" unless(fname && fname != '')
raise "No such file '#{fname}'!" unless(File.exist?(fname))
outname = fname unless(outname && outname != '')

processor = Normalize::Processor.new(
  Normalize::Filters::StringFilters::ALWAYS_SINGLE_QUOTED_EMPTY,
  Normalize::Filters::StringFilters::PREFER_SINGLE_QUOTED_NONEMPTY,
)

tokens = processor.parse(File.read(fname), fname)
tokens = processor.process(tokens)

File.open(outname, "w") do |fh|
  fh.write(tokens.map { |token| token.token }.join)
end
